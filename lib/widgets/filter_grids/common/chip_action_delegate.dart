import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/action_delegates/rename_album_dialog.dart';
import 'package:aves/widgets/common/aves_dialog.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';

class ChipActionDelegate {
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);

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

class AlbumChipActionDelegate extends ChipActionDelegate with FeedbackMixin, PermissionAwareMixin {
  final CollectionSource source;

  AlbumChipActionDelegate({
    @required this.source,
  });

  @override
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    await super.onActionSelected(context, filter, action);
    switch (action) {
      case ChipAction.delete:
        unawaited(_showDeleteDialog(context, filter as AlbumFilter));
        break;
      case ChipAction.rename:
        unawaited(_showRenameDialog(context, filter as AlbumFilter));
        break;
      default:
        break;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, AlbumFilter filter) async {
    final selection = source.rawEntries.where(filter.filter).toList();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          content: Text('Are you sure you want to delete this album and its ${Intl.plural(count, one: 'item', other: '$count items')}?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.toUpperCase()),
            ),
            FlatButton(
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
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri);
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          settings.pinnedFilters = settings.pinnedFilters..remove(filter);
        }
        if (deletedCount > 0) {
          source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)));
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

    final result = await ImageFileService.renameDirectory(album, newName);

    final albumEntries = source.rawEntries.where(filter.filter);
    final movedEntries = <ImageEntry>[];
    await Future.forEach<Map>(result, (newFields) async {
      final oldContentId = newFields['oldContentId'];
      final entry = albumEntries.firstWhere((entry) => entry.contentId == oldContentId, orElse: () => null);
      if (entry != null) {
        movedEntries.add(entry);
        await source.moveEntry(entry, newFields);
      }
    });
    final newAlbum = path.join(path.dirname(album), newName);
    source.updateAfterMove(
      entries: movedEntries,
      fromAlbums: {album},
      toAlbum: newAlbum,
      copy: false,
    );
    final newFilter = AlbumFilter(newAlbum, source.getUniqueAlbumName(newAlbum));
    settings.pinnedFilters = settings.pinnedFilters
      ..remove(filter)
      ..add(newFilter);

    showFeedback(context, 'Done!');
  }
}
