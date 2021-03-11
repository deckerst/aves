import 'dart:async';

import 'package:aves/model/actions/collection_actions.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        collection.browse();
        break;
      default:
        break;
    }
  }

  Future<void> _moveSelection(BuildContext context, {@required MoveType moveType}) async {
    final selectionDirs = selection.where((e) => e.path != null).map((e) => e.directory).toSet();
    if (moveType == MoveType.move) {
      // check whether moving is possible given OS restrictions,
      // before asking to pick a destination album
      final restrictedDirs = await AndroidFileService.getRestrictedDirectories();
      for (final selectionDir in selectionDirs) {
        final dir = VolumeRelativeDirectory.fromPath(selectionDir);
        if (restrictedDirs.contains(dir)) {
          await showRestrictedDirectoryDialog(context, dir);
          return;
        }
      }
    }

    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        settings: RouteSettings(name: AlbumPickPage.routeName),
        builder: (context) => AlbumPickPage(source: source, moveType: moveType),
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (moveType == MoveType.move && !await checkStoragePermissionForAlbums(context, selectionDirs)) return;

    if (!await checkFreeSpaceForMove(context, selection, destinationAlbum, moveType)) return;

    // do not directly use selection when moving and post-processing items
    // as source monitoring may remove obsolete items from the original selection
    final todoEntries = selection.toSet();

    final copy = moveType == MoveType.copy;
    final todoCount = todoEntries.length;
    // while the move is ongoing, source monitoring may remove entries from itself and the favourites repo
    // so we save favourites beforehand, and will mark the moved entries as such after the move
    final favouriteEntries = todoEntries.where((entry) => entry.isFavourite).toSet();
    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: ImageFileService.move(todoEntries, copy: copy, destinationAlbum: destinationAlbum),
      itemCount: todoCount,
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success).toSet();
        await source.updateAfterMove(
          todoEntries: todoEntries,
          favouriteEntries: favouriteEntries,
          copy: copy,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        collection.browse();
        source.resumeMonitoring();

        final movedCount = movedOps.length;
        if (movedCount < todoCount) {
          final count = todoCount - movedCount;
          showFeedback(context, copy ? context.l10n.collectionCopyFailureFeedback(count) : context.l10n.collectionMoveFailureFeedback(count));
        } else {
          final count = movedCount;
          showFeedback(context, copy ? context.l10n.collectionCopySuccessFeedback(count) : context.l10n.collectionMoveSuccessFeedback(count));
        }
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
          content: Text(context.l10n.deleteEntriesConfirmationDialogMessage(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.deleteButtonLabel),
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
        source.removeEntries(deletedUris);
        collection.browse();
        source.resumeMonitoring();

        final deletedCount = deletedUris.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, context.l10n.collectionDeleteFailureFeedback(count));
        }
      },
    );
  }
}
