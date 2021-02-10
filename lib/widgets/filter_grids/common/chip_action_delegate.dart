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
  final CollectionSource source;

  ChipActionDelegate({
    @required this.source,
  });

  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    switch (action) {
      case ChipAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..add(filter);
        break;
      case ChipAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..remove(filter);
        break;
      case ChipAction.hide:
        source.changeFilterVisibility(filter, false);
        break;
      default:
        break;
    }
  }
}

class AlbumChipActionDelegate extends ChipActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  AlbumChipActionDelegate({
    @required CollectionSource source,
  }) : super(source: source);

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
    final selection = source.visibleEntries.where(filter.test).toSet();
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

    final selectionCount = selection.length;
    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: ImageFileService.delete(selection),
      itemCount: selectionCount,
      onDone: (processed) {
        final deletedUris = processed.where((event) => event.success).map((event) => event.uri).toSet();
        final deletedCount = deletedUris.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        source.removeEntries(deletedUris);
        source.resumeMonitoring();
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

    final todoEntries = source.visibleEntries.where(filter.test).toSet();
    final destinationAlbum = path.join(path.dirname(album), newName);

    if (!await checkFreeSpaceForMove(context, todoEntries, destinationAlbum, MoveType.move)) return;

    final todoCount = todoEntries.length;
    // while the move is ongoing, source monitoring may remove entries from itself and the favourites repo
    // so we save favourites beforehand, and will mark the moved entries as such after the move
    final favouriteEntries = todoEntries.where((entry) => entry.isFavourite).toSet();
    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: ImageFileService.move(todoEntries, copy: false, destinationAlbum: destinationAlbum),
      itemCount: todoCount,
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success).toSet();
        final movedCount = movedOps.length;
        if (movedCount < todoCount) {
          final count = todoCount - movedCount;
          showFeedback(context, 'Failed to move ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          showFeedback(context, 'Done!');
        }
        final pinned = settings.pinnedFilters.contains(filter);
        await source.updateAfterMove(
          todoEntries: todoEntries,
          favouriteEntries: favouriteEntries,
          copy: false,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        // repin new album after obsolete album got removed and unpinned
        if (pinned) {
          final newFilter = AlbumFilter(destinationAlbum, source.getUniqueAlbumName(destinationAlbum));
          settings.pinnedFilters = settings.pinnedFilters..add(newFilter);
        }
        source.resumeMonitoring();
      },
    );
  }
}
