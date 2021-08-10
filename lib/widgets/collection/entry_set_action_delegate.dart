import 'dart:async';

import 'package:aves/model/actions/collection_actions.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/pedantic.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EntrySetActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  void onEntryActionSelected(BuildContext context, EntryAction action) {
    switch (action) {
      case EntryAction.delete:
        _showDeleteDialog(context);
        break;
      case EntryAction.share:
        _share(context);
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
        _refreshMetadata(context);
        break;
      case CollectionAction.map:
        _goToMap(context);
        break;
      case CollectionAction.stats:
        _goToStats(context);
        break;
      default:
        break;
    }
  }

  Set<AvesEntry> _getExpandedSelectedItems(Selection<AvesEntry> selection) {
    return selection.selection.expand((entry) => entry.burstEntries ?? {entry}).toSet();
  }

  void _share(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);
    AndroidAppService.shareEntries(selectedItems).then((success) {
      if (!success) showNoMatchingAppDialog(context);
    });
  }

  void _refreshMetadata(BuildContext context) {
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    source.refreshMetadata(selectedItems);
    selection.browse();
  }

  Future<void> _moveSelection(BuildContext context, {required MoveType moveType}) async {
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final selectionDirs = selectedItems.map((e) => e.directory).whereNotNull().toSet();
    if (moveType == MoveType.move) {
      // check whether moving is possible given OS restrictions,
      // before asking to pick a destination album
      final restrictedDirs = await storageService.getRestrictedDirectories();
      for (final selectionDir in selectionDirs) {
        final dir = VolumeRelativeDirectory.fromPath(selectionDir);
        if (dir == null) return;
        if (restrictedDirs.contains(dir)) {
          await showRestrictedDirectoryDialog(context, dir);
          return;
        }
      }
    }

    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: AlbumPickPage.routeName),
        builder: (context) => AlbumPickPage(source: source, moveType: moveType),
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (moveType == MoveType.move && !await checkStoragePermissionForAlbums(context, selectionDirs)) return;

    if (!await checkFreeSpaceForMove(context, selectedItems, destinationAlbum, moveType)) return;

    // do not directly use selection when moving and post-processing items
    // as source monitoring may remove obsolete items from the original selection
    final todoEntries = selectedItems.toSet();

    final copy = moveType == MoveType.copy;
    final todoCount = todoEntries.length;
    assert(todoCount > 0);

    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: imageFileService.move(todoEntries, copy: copy, destinationAlbum: destinationAlbum),
      itemCount: todoCount,
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success).toSet();
        await source.updateAfterMove(
          todoEntries: todoEntries,
          copy: copy,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        selection.browse();
        source.resumeMonitoring();

        // cleanup
        if (moveType == MoveType.move) {
          await storageService.deleteEmptyDirectories(selectionDirs);
        }

        final l10n = context.l10n;
        final movedCount = movedOps.length;
        if (movedCount < todoCount) {
          final count = todoCount - movedCount;
          showFeedback(context, copy ? l10n.collectionCopyFailureFeedback(count) : l10n.collectionMoveFailureFeedback(count));
        } else {
          final count = movedCount;
          showFeedback(
            context,
            copy ? l10n.collectionCopySuccessFeedback(count) : l10n.collectionMoveSuccessFeedback(count),
            SnackBarAction(
              label: context.l10n.showButtonLabel,
              onPressed: () async {
                final highlightInfo = context.read<HighlightInfo>();
                final collection = context.read<CollectionLens>();
                var targetCollection = collection;
                if (collection.filters.any((f) => f is AlbumFilter)) {
                  final filter = AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum));
                  // we could simply add the filter to the current collection
                  // but navigating makes the change less jarring
                  targetCollection = CollectionLens(
                    source: collection.source,
                    filters: collection.filters,
                  )..addFilter(filter);
                  unawaited(Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: CollectionPage.routeName),
                      builder: (context) => CollectionPage(
                        collection: targetCollection,
                      ),
                    ),
                  ));
                  await Future.delayed(Durations.staggeredAnimationPageTarget);
                }
                await Future.delayed(Durations.highlightScrollInitDelay);
                final newUris = movedOps.map((v) => v.newFields['uri'] as String?).toSet();
                final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                if (targetEntry != null) {
                  highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                }
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);
    final selectionDirs = selectedItems.map((e) => e.directory).whereNotNull().toSet();
    final todoCount = selectedItems.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(context.l10n.deleteEntriesConfirmationDialogMessage(todoCount)),
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

    if (!await checkStoragePermissionForAlbums(context, selectionDirs)) return;

    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: imageFileService.delete(selectedItems),
      itemCount: todoCount,
      onDone: (processed) async {
        final deletedUris = processed.where((event) => event.success).map((event) => event.uri).toSet();
        await source.removeEntries(deletedUris);
        selection.browse();
        source.resumeMonitoring();

        final deletedCount = deletedUris.length;
        if (deletedCount < todoCount) {
          final count = todoCount - deletedCount;
          showFeedback(context, context.l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyDirectories(selectionDirs);
      },
    );
  }

  void _goToMap(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final entries = selection.isSelecting ? _getExpandedSelectedItems(selection) : context.read<CollectionLens>().sortedEntries;

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(
          entries: entries.where((entry) => entry.hasGps).toList(),
        ),
      ),
    );
  }

  void _goToStats(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final collection = context.read<CollectionLens>();
    final entries = selection.isSelecting ? _getExpandedSelectedItems(selection) : collection.sortedEntries.toSet();

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: StatsPage.routeName),
        builder: (context) => StatsPage(
          entries: entries,
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }
}
