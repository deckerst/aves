import 'dart:async';

import 'package:aves/model/actions/collection_actions.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class EntrySetActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  final CollectionLens collection;

  CollectionSource get source => collection.source;

  Set<AvesEntry> get selection => collection.selection;

  EntrySetActionDelegate({
    @required this.collection,
  });

  void onEntryActionSelected(BuildContext context, EntryAction action) {
    switch (action) {
      case EntryAction.delete:
        _showDeleteDialog(context);
        break;
      case EntryAction.share:
        AndroidAppService.shareEntries(selection).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      default:
        break;
    }
  }

  void onCollectionActionSelected(BuildContext context, CollectionAction action) {
    switch (action) {
      case CollectionAction.copy:
        _moveSelection(context, moveType: MoveType.copy);
        break;
      case CollectionAction.move:
        _moveSelection(context, moveType: MoveType.move);
        break;
      case CollectionAction.refreshMetadata:
        source.refreshMetadata(selection);
        collection.clearSelection();
        collection.browse();
        break;
      default:
        break;
    }
  }

  Future<void> _moveSelection(BuildContext context, {@required MoveType moveType}) async {
    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        settings: RouteSettings(name: AlbumPickPage.routeName),
        builder: (context) => AlbumPickPage(source: source, moveType: moveType),
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (!await checkStoragePermission(context, selection)) return;

    if (!await checkFreeSpaceForMove(context, selection, destinationAlbum, moveType)) return;

    final copy = moveType == MoveType.copy;
    showOpReport<MoveOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.move(selection, copy: copy, destinationAlbum: destinationAlbum),
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final selectionCount = selection.length;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          showFeedback(context, 'Failed to ${copy ? 'copy' : 'move'} ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          final count = movedCount;
          showFeedback(context, '${copy ? 'Copied' : 'Moved'} ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        await source.updateAfterMove(
          selection: selection,
          copy: copy,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        collection.clearSelection();
        collection.browse();
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text('Are you sure you want to delete ${Intl.plural(count, one: 'this item', other: 'these $count items')}?'),
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
        collection.clearSelection();
        collection.browse();
      },
    );
  }
}
