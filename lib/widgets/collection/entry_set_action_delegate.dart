import 'dart:async';
import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_xmp_iptc.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EntrySetActionDelegate with EntryEditorMixin, FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  bool isVisible(
    EntrySetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required EntrySortFactor sortFactor,
    required int itemCount,
    required int selectedItemCount,
  }) {
    switch (action) {
      // general
      case EntrySetAction.sort:
        return true;
      case EntrySetAction.group:
        return sortFactor == EntrySortFactor.date;
      case EntrySetAction.select:
        return appMode.canSelect && !isSelecting;
      case EntrySetAction.selectAll:
        return isSelecting && selectedItemCount < itemCount;
      case EntrySetAction.selectNone:
        return isSelecting && selectedItemCount == itemCount;
      // browsing
      case EntrySetAction.searchCollection:
        return appMode.canSearch && !isSelecting;
      case EntrySetAction.toggleTitleSearch:
        return !isSelecting;
      case EntrySetAction.addShortcut:
        return appMode == AppMode.main && !isSelecting && device.canPinShortcut;
      // browsing or selecting
      case EntrySetAction.map:
      case EntrySetAction.stats:
        return appMode == AppMode.main;
      // selecting
      case EntrySetAction.share:
      case EntrySetAction.delete:
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rescan:
      case EntrySetAction.rotateCCW:
      case EntrySetAction.rotateCW:
      case EntrySetAction.flip:
      case EntrySetAction.editDate:
      case EntrySetAction.editTags:
      case EntrySetAction.removeMetadata:
        return appMode == AppMode.main && isSelecting;
    }
  }

  bool canApply(
    EntrySetAction action, {
    required bool isSelecting,
    required int itemCount,
    required int selectedItemCount,
  }) {
    final hasItems = itemCount > 0;
    final hasSelection = selectedItemCount > 0;

    switch (action) {
      case EntrySetAction.sort:
      case EntrySetAction.group:
        return true;
      case EntrySetAction.select:
        return hasItems;
      case EntrySetAction.selectAll:
        return selectedItemCount < itemCount;
      case EntrySetAction.selectNone:
        return hasSelection;
      case EntrySetAction.searchCollection:
      case EntrySetAction.toggleTitleSearch:
      case EntrySetAction.addShortcut:
        return true;
      case EntrySetAction.map:
      case EntrySetAction.stats:
        return (!isSelecting && hasItems) || (isSelecting && hasSelection);
      // selecting
      case EntrySetAction.share:
      case EntrySetAction.delete:
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rescan:
      case EntrySetAction.rotateCCW:
      case EntrySetAction.rotateCW:
      case EntrySetAction.flip:
      case EntrySetAction.editDate:
      case EntrySetAction.editTags:
      case EntrySetAction.removeMetadata:
        return hasSelection;
    }
  }

  void onActionSelected(BuildContext context, EntrySetAction action) {
    switch (action) {
      // general
      case EntrySetAction.sort:
      case EntrySetAction.group:
      case EntrySetAction.select:
      case EntrySetAction.selectAll:
      case EntrySetAction.selectNone:
        break;
      // browsing
      case EntrySetAction.searchCollection:
        _goToSearch(context);
        break;
      case EntrySetAction.toggleTitleSearch:
        context.read<Query>().toggle();
        break;
      case EntrySetAction.addShortcut:
        _addShortcut(context);
        break;
      // browsing or selecting
      case EntrySetAction.map:
        _goToMap(context);
        break;
      case EntrySetAction.stats:
        _goToStats(context);
        break;
      // selecting
      case EntrySetAction.share:
        _share(context);
        break;
      case EntrySetAction.delete:
        _delete(context);
        break;
      case EntrySetAction.copy:
        _move(context, moveType: MoveType.copy);
        break;
      case EntrySetAction.move:
        _move(context, moveType: MoveType.move);
        break;
      case EntrySetAction.rescan:
        _rescan(context);
        break;
      case EntrySetAction.rotateCCW:
        _rotate(context, clockwise: false);
        break;
      case EntrySetAction.rotateCW:
        _rotate(context, clockwise: true);
        break;
      case EntrySetAction.flip:
        _flip(context);
        break;
      case EntrySetAction.editDate:
        _editDate(context);
        break;
      case EntrySetAction.editTags:
        _editTags(context);
        break;
      case EntrySetAction.removeMetadata:
        _removeMetadata(context);
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

  Future<void> _delete(BuildContext context) async {
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

  Future<void> _move(BuildContext context, {required MoveType moveType}) async {
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
    final todoItems = selectedItems.toSet();

    final copy = moveType == MoveType.copy;
    final todoCount = todoItems.length;
    assert(todoCount > 0);

    final destinationDirectory = Directory(destinationAlbum);
    final names = [
      ...todoItems.map((v) => '${v.filenameWithoutExtension}${v.extension}'),
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
        todoItems,
        copy: copy,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: nameConflictStrategy,
      ),
      itemCount: todoCount,
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final movedOps = successOps.where((e) => !e.newFields.containsKey('skipped')).toSet();
        await source.updateAfterMove(
          todoEntries: todoItems,
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

  Future<void> _edit(
    BuildContext context,
    Selection<AvesEntry> selection,
    Set<AvesEntry> todoItems,
    Future<Set<EntryDataType>> Function(AvesEntry entry) op,
  ) async {
    final selectionDirs = todoItems.map((e) => e.directory).whereNotNull().toSet();
    final todoCount = todoItems.length;

    if (!await checkStoragePermissionForAlbums(context, selectionDirs, entries: todoItems)) return;

    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: Stream.fromIterable(todoItems).asyncMap((entry) async {
        final dataTypes = await op(entry);
        return ImageOpEvent(success: dataTypes.isNotEmpty, uri: entry.uri);
      }).asBroadcastStream(),
      itemCount: todoCount,
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        selection.browse();
        source.resumeMonitoring();
        unawaited(source.refreshUris(successOps.map((v) => v.uri).toSet()));

        final l10n = context.l10n;
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

  Future<Set<AvesEntry>?> _getEditableItems(
    BuildContext context, {
    required Set<AvesEntry> selectedItems,
    required bool Function(AvesEntry entry) canEdit,
  }) async {
    final bySupported = groupBy<AvesEntry, bool>(selectedItems, canEdit);
    final supported = (bySupported[true] ?? []).toSet();
    final unsupported = (bySupported[false] ?? []).toSet();

    if (unsupported.isEmpty) return supported;

    final unsupportedTypes = unsupported.map((entry) => entry.mimeType).toSet().map(MimeUtils.displayType).toList()..sort();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AvesDialog(
          context: context,
          title: l10n.unsupportedTypeDialogTitle,
          content: Text(l10n.unsupportedTypeDialogMessage(unsupportedTypes.length, unsupportedTypes.join(', '))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            if (supported.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.continueButtonLabel),
              ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return null;

    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation);
    return supported;
  }

  Future<void> _rotate(BuildContext context, {required bool clockwise}) async {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final todoItems = await _getEditableItems(context, selectedItems: selectedItems, canEdit: (entry) => entry.canRotateAndFlip);
    if (todoItems == null || todoItems.isEmpty) return;

    await _edit(context, selection, todoItems, (entry) => entry.rotate(clockwise: clockwise, persist: true));
  }

  Future<void> _flip(BuildContext context) async {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final todoItems = await _getEditableItems(context, selectedItems: selectedItems, canEdit: (entry) => entry.canRotateAndFlip);
    if (todoItems == null || todoItems.isEmpty) return;

    await _edit(context, selection, todoItems, (entry) => entry.flip(persist: true));
  }

  Future<void> _editDate(BuildContext context) async {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final todoItems = await _getEditableItems(context, selectedItems: selectedItems, canEdit: (entry) => entry.canEditDate);
    if (todoItems == null || todoItems.isEmpty) return;

    final modifier = await selectDateModifier(context, todoItems);
    if (modifier == null) return;

    await _edit(context, selection, todoItems, (entry) => entry.editDate(modifier));
  }

  Future<void> _editTags(BuildContext context) async {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final todoItems = await _getEditableItems(context, selectedItems: selectedItems, canEdit: (entry) => entry.canEditTags);
    if (todoItems == null || todoItems.isEmpty) return;

    final newTagsByEntry = await selectTags(context, todoItems);
    if (newTagsByEntry == null) return;

    // only process modified items
    todoItems.removeWhere((entry) {
      final newTags = newTagsByEntry[entry] ?? entry.tags;
      final currentTags = entry.tags;
      return newTags.length == currentTags.length && newTags.every(currentTags.contains);
    });

    if (todoItems.isEmpty) return;

    await _edit(context, selection, todoItems, (entry) => entry.editTags(newTagsByEntry[entry]!));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final selection = context.read<Selection<AvesEntry>>();
    final selectedItems = _getExpandedSelectedItems(selection);

    final todoItems = await _getEditableItems(context, selectedItems: selectedItems, canEdit: (entry) => entry.canRemoveMetadata);
    if (todoItems == null || todoItems.isEmpty) return;

    final types = await selectMetadataToRemove(context, todoItems);
    if (types == null || types.isEmpty) return;

    await _edit(context, selection, todoItems, (entry) => entry.removeMetadata(types));
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

  void _goToSearch(BuildContext context) {
    final collection = context.read<CollectionLens>();

    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }

  Future<void> _addShortcut(BuildContext context) async {
    final collection = context.read<CollectionLens>();
    final filters = collection.filters;

    String? defaultName;
    if (filters.isNotEmpty) {
      // we compute the default name beforehand
      // because some filter labels need localization
      final sortedFilters = List<CollectionFilter>.from(filters)..sort();
      defaultName = sortedFilters.first.getLabel(context).replaceAll('\n', ' ');
    }
    final result = await showDialog<Tuple2<AvesEntry?, String>>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: defaultName ?? '',
        collection: collection,
      ),
    );
    if (result == null) return;

    final coverEntry = result.item1;
    final name = result.item2;
    if (name.isEmpty) return;

    unawaited(androidAppService.pinToHomeScreen(name, coverEntry, filters: filters));
  }
}
