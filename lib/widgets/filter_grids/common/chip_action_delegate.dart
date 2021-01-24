import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/rename_album_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ChipActionDelegate {
  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    switch (action) {
      case ChipAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..add(filter);
        break;
      case ChipAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..remove(filter);
        break;
      default:
        break;
    }
  }
}

class AlbumChipActionDelegate extends ChipActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  final CollectionSource source;

  AlbumChipActionDelegate({
    @required this.source,
  });

  @override
  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    super.onActionSelected(context, filter, action);
    switch (action) {
      case ChipAction.delete:
        _showDeleteDialog(context, filter as AlbumFilter);
        break;
      case ChipAction.rename:
        _showRenameDialog(context, filter as AlbumFilter);
        break;
      default:
        break;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, AlbumFilter filter) async {
    final selection = source.rawEntries.where(filter.filter).toSet();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text('Are you sure you want to delete this album and its ${Intl.plural(count, one: 'item', other: '$count items')}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.toUpperCase()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.toUpperCase()),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, selection)) return;

    showOpReport<ImageOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri).toList();
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        if (deletedCount > 0) {
          source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)).toList());
        }
      },
    );
  }

  Future<void> _showRenameDialog(BuildContext context, AlbumFilter filter) async {
    final album = filter.album;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameAlbumDialog(album),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

    final selection = source.rawEntries.where(filter.filter).toSet();
    final destinationAlbum = path.join(path.dirname(album), newName);

    if (!await checkFreeSpaceForMove(context, selection, destinationAlbum, MoveType.move)) return;

    showOpReport<MoveOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.move(selection, copy: false, destinationAlbum: destinationAlbum),
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final selectionCount = selection.length;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          showFeedback(context, 'Failed to move ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          showFeedback(context, 'Done!');
        }
        final pinned = settings.pinnedFilters.contains(filter);
        await source.updateAfterMove(
          selection: selection,
          copy: false,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        // repin new album after obsolete album got removed and unpinned
        if (pinned) {
          final newFilter = AlbumFilter(destinationAlbum, source.getUniqueAlbumName(destinationAlbum));
          settings.pinnedFilters = settings.pinnedFilters..add(newFilter);
        }
      },
    );
  }
}
