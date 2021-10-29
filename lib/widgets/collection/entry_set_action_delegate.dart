import 'dart:async';
import 'dart:io';

import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/dialogs/edit_entry_date_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EntrySetActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  void onActionSelected(BuildContext context, EntrySetAction action) {
    switch (action) {
      case EntrySetAction.share:
        _share(context);
        break;
      case EntrySetAction.delete:
        _showDeleteDialog(context);
        break;
      case EntrySetAction.copy:
        _moveSelection(context, moveType: MoveType.copy);
        break;
      case EntrySetAction.move:
        _moveSelection(context, moveType: MoveType.move);
        break;
      case EntrySetAction.rescan:
        _rescan(context);
        break;
      case EntrySetAction.editDate:
        _editDate(context);
        break;
      case EntrySetAction.map:
        _goToMap(context);
        break;
      case EntrySetAction.stats:
        _goToStats(context);
        break;
      default:
        break;
    }
  }

  Set<AvesEntry> _getExpandedSelectedItems(Selection<AvesEntry> selection) {
    return selection.selectedItems.expand((entry) => entry.burstEntries ?? {entry}).toSet();
  }

  void _share(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);
    androidAppService.shareEntries(selectedItems).then((success) {
      if (!success) showNoMatchingAppDialog(context);
    });
  }

  void _rescan(BuildContext context) {
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final controller = AnalysisController(canStartService: true, force: true);
    source.analyze(controller, entries: selectedItems);

    selection.browse();
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

    if (!await checkStoragePermissionForAlbums(context, selectionDirs, entries: selectedItems)) return;

    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: mediaFileService.delete(selectedItems),
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

  Future<void> _moveSelection(BuildContext context, {required MoveType moveType}) async {
    final l10n = context.l10n;
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);
    final selectionDirs = selectedItems.map((e) => e.directory).whereNotNull().toSet();

    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: AlbumPickPage.routeName),
        builder: (context) => AlbumPickPage(source: source, moveType: moveType),
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (moveType == MoveType.move && !await checkStoragePermissionForAlbums(context, selectionDirs, entries: selectedItems)) return;

    if (!await checkFreeSpaceForMove(context, selectedItems, destinationAlbum, moveType)) return;

    // do not directly use selection when moving and post-processing items
    // as source monitoring may remove obsolete items from the original selection
    final todoEntries = selectedItems.toSet();

    final copy = moveType == MoveType.copy;
    final todoCount = todoEntries.length;
    assert(todoCount > 0);

    final destinationDirectory = Directory(destinationAlbum);
    final names = [
      ...todoEntries.map((v) => '${v.filenameWithoutExtension}${v.extension}'),
      // do not guard up front based on directory existence,
      // as conflicts could be within moved entries scattered across multiple albums
      if (await destinationDirectory.exists()) ...destinationDirectory.listSync().map((v) => pContext.basename(v.path)),
    ];
    final uniqueNames = names.toSet();
    var nameConflictStrategy = NameConflictStrategy.rename;
    if (uniqueNames.length < names.length) {
      final value = await showDialog<NameConflictStrategy>(
        context: context,
        builder: (context) {
          return AvesSelectionDialog<NameConflictStrategy>(
            initialValue: nameConflictStrategy,
            options: Map.fromEntries(NameConflictStrategy.values.map((v) => MapEntry(v, v.getName(context)))),
            message: selectionDirs.length == 1 ? l10n.nameConflictDialogSingleSourceMessage : l10n.nameConflictDialogMultipleSourceMessage,
            confirmationButtonLabel: l10n.continueButtonLabel,
          );
        },
      );
      if (value == null) return;
      nameConflictStrategy = value;
    }

    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: mediaFileService.move(
        todoEntries,
        copy: copy,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: nameConflictStrategy,
      ),
      itemCount: todoCount,
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final movedOps = successOps.where((e) => !e.newFields.containsKey('skipped')).toSet();
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

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, copy ? l10n.collectionCopyFailureFeedback(count) : l10n.collectionMoveFailureFeedback(count));
        } else {
          final count = movedOps.length;
          showFeedback(
            context,
            copy ? l10n.collectionCopySuccessFeedback(count) : l10n.collectionMoveSuccessFeedback(count),
            count > 0
                ? SnackBarAction(
                    label: l10n.showButtonLabel,
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
                        final delayDuration = context.read<DurationsData>().staggeredAnimationPageTarget;
                        await Future.delayed(delayDuration);
                      }
                      await Future.delayed(Durations.highlightScrollInitDelay);
                      final newUris = movedOps.map((v) => v.newFields['uri'] as String?).toSet();
                      final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                      if (targetEntry != null) {
                        highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                      }
                    },
                  )
                : null,
          );
        }
      },
    );
  }

  Future<void> _editDate(BuildContext context) async {
    final l10n = context.l10n;
    final source = context.read<CollectionSource>();
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final bySupported = groupBy<AvesEntry, bool>(selectedItems, (entry) => entry.canEditExif);
    final todoEntries = (bySupported[true] ?? []).toSet();
    final unsupportedItems = (bySupported[false] ?? []);
    if (unsupportedItems.isNotEmpty) {
      final unsupportedTypes = unsupportedItems.map((entry) => entry.mimeType).toSet().map(MimeUtils.displayType).toList()..sort();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AvesDialog(
            context: context,
            title: l10n.unsupportedTypeDialogTitle,
            content: Text(l10n.unsupportedTypeDialogMessage(unsupportedTypes.length, unsupportedTypes.join(', '))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              if (todoEntries.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.continueButtonLabel),
                ),
            ],
          );
        },
      );
      if (confirmed == null || !confirmed) return;
    }

    final selectionDirs = todoEntries.map((e) => e.directory).whereNotNull().toSet();
    final todoCount = todoEntries.length;

    final modifier = await showDialog<DateModifier>(
      context: context,
      builder: (context) => EditEntryDateDialog(entry: todoEntries.first),
    );
    if (modifier == null) return;

    if (!await checkStoragePermissionForAlbums(context, selectionDirs, entries: todoEntries)) return;

    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: Stream.fromIterable(todoEntries).asyncMap((entry) async {
        final success = await entry.editDate(modifier);
        return ImageOpEvent(success: success, uri: entry.uri);
      }).asBroadcastStream(),
      itemCount: todoCount,
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        selection.browse();
        source.resumeMonitoring();
        unawaited(source.refreshUris(successOps.map((v) => v.uri).toSet()));

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, l10n.collectionEditFailureFeedback(count));
        } else {
          final count = successCount;
          showFeedback(context, l10n.collectionEditSuccessFeedback(count));
        }
      },
    );
  }

  void _goToMap(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final collection = context.read<CollectionLens>();
    final entries = (selection.isSelecting ? _getExpandedSelectedItems(selection) : collection.sortedEntries);

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(
          // need collection with fresh ID to prevent hero from scroller on Map page to Collection page
          collection: CollectionLens(
            source: collection.source,
            filters: collection.filters,
            fixedSelection: entries.where((entry) => entry.hasGps).toList(),
          ),
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
