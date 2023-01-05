import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/rename_entry_set_page.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/location_pick_page.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../common/action_mixins/entry_storage.dart';

class EntrySetActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, EntryEditorMixin, EntryStorageMixin {
  bool isVisible(
    EntrySetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required int selectedItemCount,
    required bool isTrash,
  }) {
    final canWrite = !device.isReadOnly;
    final isMain = appMode == AppMode.main;
    switch (action) {
      // general
      case EntrySetAction.configureView:
        return true;
      case EntrySetAction.select:
        return appMode.canSelectMedia && !isSelecting;
      case EntrySetAction.selectAll:
        return isSelecting && selectedItemCount < itemCount;
      case EntrySetAction.selectNone:
        return isSelecting && selectedItemCount == itemCount;
      // browsing
      case EntrySetAction.searchCollection:
        return !settings.useTvLayout && appMode.canNavigate && !isSelecting;
      case EntrySetAction.toggleTitleSearch:
        return !isSelecting;
      case EntrySetAction.addShortcut:
        return isMain && !isSelecting && device.canPinShortcut && !isTrash;
      case EntrySetAction.emptyBin:
        return canWrite && isMain && isTrash;
      // browsing or selecting
      case EntrySetAction.map:
      case EntrySetAction.slideshow:
      case EntrySetAction.stats:
        return isMain;
      case EntrySetAction.rescan:
        return !settings.useTvLayout && isMain && !isTrash;
      // selecting
      case EntrySetAction.share:
      case EntrySetAction.toggleFavourite:
        return isMain && isSelecting && !isTrash;
      case EntrySetAction.delete:
        return canWrite && isMain && isSelecting;
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rename:
      case EntrySetAction.rotateCCW:
      case EntrySetAction.rotateCW:
      case EntrySetAction.flip:
      case EntrySetAction.editDate:
      case EntrySetAction.editLocation:
      case EntrySetAction.editTitleDescription:
      case EntrySetAction.editRating:
      case EntrySetAction.editTags:
      case EntrySetAction.removeMetadata:
        return canWrite && isMain && isSelecting && !isTrash;
      case EntrySetAction.restore:
        return canWrite && isMain && isSelecting && isTrash;
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
      case EntrySetAction.configureView:
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
      case EntrySetAction.emptyBin:
        return !isSelecting && hasItems;
      case EntrySetAction.map:
      case EntrySetAction.slideshow:
      case EntrySetAction.stats:
      case EntrySetAction.rescan:
        return (!isSelecting && hasItems) || (isSelecting && hasSelection);
      // selecting
      case EntrySetAction.share:
      case EntrySetAction.delete:
      case EntrySetAction.restore:
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rename:
      case EntrySetAction.toggleFavourite:
      case EntrySetAction.rotateCCW:
      case EntrySetAction.rotateCW:
      case EntrySetAction.flip:
      case EntrySetAction.editDate:
      case EntrySetAction.editLocation:
      case EntrySetAction.editTitleDescription:
      case EntrySetAction.editRating:
      case EntrySetAction.editTags:
      case EntrySetAction.removeMetadata:
        return hasSelection;
    }
  }

  void onActionSelected(BuildContext context, EntrySetAction action) {
    switch (action) {
      // general
      case EntrySetAction.configureView:
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
      case EntrySetAction.slideshow:
        _goToSlideshow(context);
        break;
      case EntrySetAction.stats:
        _goToStats(context);
        break;
      case EntrySetAction.rescan:
        _rescan(context);
        break;
      // selecting
      case EntrySetAction.share:
        _share(context);
        break;
      case EntrySetAction.delete:
      case EntrySetAction.emptyBin:
        _delete(context);
        break;
      case EntrySetAction.restore:
        _move(context, moveType: MoveType.fromBin);
        break;
      case EntrySetAction.copy:
        _move(context, moveType: MoveType.copy);
        break;
      case EntrySetAction.move:
        _move(context, moveType: MoveType.move);
        break;
      case EntrySetAction.rename:
        _rename(context);
        break;
      case EntrySetAction.toggleFavourite:
        _toggleFavourite(context);
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
        editDate(context);
        break;
      case EntrySetAction.editLocation:
        _editLocation(context);
        break;
      case EntrySetAction.editTitleDescription:
        _editTitleDescription(context);
        break;
      case EntrySetAction.editRating:
        _editRating(context);
        break;
      case EntrySetAction.editTags:
        _editTags(context);
        break;
      case EntrySetAction.removeMetadata:
        _removeMetadata(context);
        break;
    }
  }

  void _leaveSelectionMode(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>?>();
    selection?.browse();
  }

  Set<AvesEntry> _getTargetItems(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final groupedEntries = (selection.isSelecting ? selection.selectedItems : context.read<CollectionLens>().sortedEntries);
    return groupedEntries.expand((entry) => entry.burstEntries ?? {entry}).toSet();
  }

  void _share(BuildContext context) {
    final entries = _getTargetItems(context);
    androidAppService.shareEntries(entries).then((success) {
      if (!success) showNoMatchingAppDialog(context);
    });
  }

  void _rescan(BuildContext context) {
    final entries = _getTargetItems(context);

    final controller = AnalysisController(canStartService: true, force: true);
    final collection = context.read<CollectionLens>();
    collection.source.analyze(controller, entries: entries);

    _leaveSelectionMode(context);
  }

  Future<void> _delete(BuildContext context) async {
    final entries = _getTargetItems(context);

    final pureTrash = entries.every((entry) => entry.trashed);
    if (settings.enableBin && !pureTrash) {
      await _move(context, moveType: MoveType.toBin);
      return;
    }

    final l10n = context.l10n;
    final source = context.read<CollectionSource>();
    final storageDirs = entries.map((e) => e.storageDirectory).whereNotNull().toSet();
    final todoCount = entries.length;

    if (!await showConfirmationDialog(
      context: context,
      type: ConfirmationDialog.deleteForever,
      message: l10n.deleteEntriesConfirmationDialogMessage(todoCount),
      confirmationButtonLabel: l10n.deleteButtonLabel,
    )) return;

    if (!await checkStoragePermissionForAlbums(context, storageDirs, entries: entries)) return;

    source.pauseMonitoring();
    final opId = mediaEditService.newOpId;
    await showOpReport<ImageOpEvent>(
      context: context,
      opStream: mediaEditService.delete(opId: opId, entries: entries),
      itemCount: todoCount,
      onCancel: () => mediaEditService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final deletedOps = successOps.where((e) => !e.skipped).toSet();
        final deletedUris = deletedOps.map((event) => event.uri).toSet();
        await source.removeEntries(deletedUris, includeTrash: true);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, context.l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyDirectories(storageDirs);
      },
    );

    _leaveSelectionMode(context);
  }

  Future<void> _move(BuildContext context, {required MoveType moveType}) async {
    final entries = _getTargetItems(context);
    await doMove(context, moveType: moveType, entries: entries);

    _leaveSelectionMode(context);
  }

  Future<void> _rename(BuildContext context) async {
    final entries = _getTargetItems(context).toList();

    final pattern = await Navigator.push<NamingPattern>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: RenameEntrySetPage.routeName),
        builder: (context) => RenameEntrySetPage(
          entries: entries,
        ),
      ),
    );
    if (pattern == null) return;

    final entriesToNewName = Map.fromEntries(entries.mapIndexed((index, entry) {
      final newName = pattern.apply(entry, index);
      return MapEntry(entry, '$newName${entry.extension}');
    })).whereNotNullValue();
    await rename(context, entriesToNewName: entriesToNewName, persist: true);

    _leaveSelectionMode(context);
  }

  Future<void> _toggleFavourite(BuildContext context) async {
    final entries = _getTargetItems(context);
    if (entries.every((entry) => entry.isFavourite)) {
      await favourites.removeEntries(entries);
    } else {
      await favourites.add(entries);
    }

    _leaveSelectionMode(context);
  }

  Future<void> _edit(
    BuildContext context,
    Set<AvesEntry> todoItems,
    Future<Set<EntryDataType>> Function(AvesEntry entry) op, {
    bool showResult = true,
  }) async {
    final selectionDirs = todoItems.map((e) => e.directory).whereNotNull().toSet();
    final todoCount = todoItems.length;

    if (!await checkStoragePermissionForAlbums(context, selectionDirs, entries: todoItems)) return;

    Set<String> obsoleteTags = todoItems.expand((entry) => entry.tags).toSet();
    Set<String> obsoleteCountryCodes = todoItems.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.countryCode).whereNotNull().toSet();

    final dataTypes = <EntryDataType>{};
    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    var cancelled = false;
    await showOpReport<ImageOpEvent>(
      context: context,
      opStream: Stream.fromIterable(todoItems).asyncMap((entry) async {
        if (cancelled) {
          return ImageOpEvent(success: true, skipped: true, uri: entry.uri);
        } else {
          final opDataTypes = await op(entry);
          dataTypes.addAll(opDataTypes);
          return ImageOpEvent(success: opDataTypes.isNotEmpty, skipped: false, uri: entry.uri);
        }
      }).asBroadcastStream(),
      itemCount: todoCount,
      onCancel: () => cancelled = true,
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final editedOps = successOps.where((e) => !e.skipped).toSet();
        source.resumeMonitoring();

        unawaited(source.refreshUris(editedOps.map((v) => v.uri).toSet()).then((_) {
          // invalidate filters derived from values before edition
          // this invalidation must happen after the source is refreshed,
          // otherwise filter chips may eagerly rebuild in between with the old state
          if (obsoleteCountryCodes.isNotEmpty) {
            source.invalidateCountryFilterSummary(countryCodes: obsoleteCountryCodes);
          }
          if (obsoleteTags.isNotEmpty) {
            source.invalidateTagFilterSummary(tags: obsoleteTags);
          }
        }));

        if (dataTypes.contains(EntryDataType.aspectRatio)) {
          source.onAspectRatioChanged();
        }

        if (showResult) {
          final l10n = context.l10n;
          final successCount = successOps.length;
          if (successCount < todoCount) {
            final count = todoCount - successCount;
            showFeedback(context, l10n.collectionEditFailureFeedback(count));
          } else {
            final count = editedOps.length;
            showFeedback(context, l10n.collectionEditSuccessFeedback(count));
          }
        }
      },
    );
    _leaveSelectionMode(context);
  }

  Future<Set<AvesEntry>?> _getEditableTargetItems(
    BuildContext context, {
    required bool Function(AvesEntry entry) canEdit,
  }) =>
      _getEditableItems(context, _getTargetItems(context), canEdit: canEdit);

  Future<Set<AvesEntry>?> _getEditableItems(
    BuildContext context,
    Set<AvesEntry> entries, {
    required bool Function(AvesEntry entry) canEdit,
  }) async {
    final bySupported = groupBy<AvesEntry, bool>(entries, canEdit);
    final supported = (bySupported[true] ?? []).toSet();
    final unsupported = (bySupported[false] ?? []).toSet();

    if (unsupported.isEmpty) return supported;

    final unsupportedTypes = unsupported.map((entry) => entry.mimeType).toSet().map(MimeUtils.displayType).toList()..sort();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AvesDialog(
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
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    return supported;
  }

  Future<void> _rotate(BuildContext context, {required bool clockwise}) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canRotate);
    if (entries == null || entries.isEmpty) return;

    await _edit(context, entries, (entry) => entry.rotate(clockwise: clockwise));
  }

  Future<void> _flip(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canFlip);
    if (entries == null || entries.isEmpty) return;

    await _edit(context, entries, (entry) => entry.flip());
  }

  Future<void> editDate(BuildContext context, {Set<AvesEntry>? entries, DateModifier? modifier, bool showResult = true}) async {
    entries ??= await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditDate);
    if (entries == null || entries.isEmpty) return;

    if (modifier == null) {
      final collection = context.read<CollectionLens>();
      modifier = await selectDateModifier(context, entries, collection);
    }
    if (modifier == null) return;

    await _edit(context, entries, (entry) => entry.editDate(modifier!), showResult: showResult);
  }

  Future<void> _editLocation(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditLocation);
    if (entries == null || entries.isEmpty) return;

    final collection = context.read<CollectionLens>();
    final location = await selectLocation(context, entries, collection);
    if (location == null) return;

    await _edit(context, entries, (entry) => entry.editLocation(location));
  }

  Future<LatLng?> editLocationByMap(BuildContext context, Set<AvesEntry> entries, LatLng clusterLocation, CollectionLens mapCollection) async {
    final editableEntries = await _getEditableItems(context, entries, canEdit: (entry) => entry.canEditLocation);
    if (editableEntries == null || editableEntries.isEmpty) return null;

    final location = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: LocationPickPage.routeName),
        builder: (context) => LocationPickPage(
          collection: mapCollection,
          initialLocation: clusterLocation,
        ),
        fullscreenDialog: true,
      ),
    );
    if (location == null) return null;

    await _edit(context, editableEntries, (entry) => entry.editLocation(location));
    return location;
  }

  Future<void> removeLocation(BuildContext context, Set<AvesEntry> entries) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          content: Text(context.l10n.genericDangerWarningDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.applyButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    final editableEntries = await _getEditableItems(context, entries, canEdit: (entry) => entry.canEditLocation);
    if (editableEntries == null || editableEntries.isEmpty) return;

    await _edit(context, editableEntries, (entry) => entry.editLocation(ExtraAvesEntryMetadataEdition.removalLocation));
  }

  Future<void> _editTitleDescription(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditTitleDescription);
    if (entries == null || entries.isEmpty) return;

    final modifier = await selectTitleDescriptionModifier(context, entries);
    if (modifier == null) return;

    await _edit(context, entries, (entry) => entry.editTitleDescription(modifier));
  }

  Future<void> _editRating(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditRating);
    if (entries == null || entries.isEmpty) return;

    final rating = await selectRating(context, entries);
    if (rating == null) return;

    await _edit(context, entries, (entry) => entry.editRating(rating));
  }

  Future<void> _editTags(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditTags);
    if (entries == null || entries.isEmpty) return;

    final newTagsByEntry = await selectTags(context, entries);
    if (newTagsByEntry == null) return;

    // only process modified items
    entries.removeWhere((entry) {
      final newTags = newTagsByEntry[entry] ?? entry.tags;
      final currentTags = entry.tags;
      return newTags.length == currentTags.length && newTags.every(currentTags.contains);
    });

    if (entries.isEmpty) return;

    await _edit(context, entries, (entry) => entry.editTags(newTagsByEntry[entry]!));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canRemoveMetadata);
    if (entries == null || entries.isEmpty) return;

    final types = await selectMetadataToRemove(context, entries);
    if (types == null || types.isEmpty) return;

    await _edit(context, entries, (entry) => entry.removeMetadata(types));
  }

  Future<void> _goToMap(BuildContext context) async {
    final collection = context.read<CollectionLens>();
    final entries = _getTargetItems(context);

    // need collection with fresh ID to prevent hero from scroller on Map page to Collection page
    final mapCollection = CollectionLens(
      source: collection.source,
      filters: collection.filters,
      fixedSelection: entries.where((entry) => entry.hasGps).toList(),
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(collection: mapCollection),
      ),
    );
    mapCollection.dispose();
  }

  void _goToSlideshow(BuildContext context) {
    final collection = context.read<CollectionLens>();
    final entries = _getTargetItems(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: SlideshowPage.routeName),
        builder: (context) {
          return SlideshowPage(
            collection: CollectionLens(
              source: collection.source,
              filters: collection.filters,
              fixedSelection: entries.toList(),
            ),
          );
        },
      ),
    );
  }

  void _goToStats(BuildContext context) {
    final collection = context.read<CollectionLens>();
    final entries = _getTargetItems(context);

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
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
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

    await androidAppService.pinToHomeScreen(name, coverEntry, filters: filters);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    }
  }
}
