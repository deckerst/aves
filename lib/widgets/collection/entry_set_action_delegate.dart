import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aves/app_mode.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/set_and.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/convert_entry_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/rename_entry_set_page.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_dynamic_album_dialog.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/location_pick_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/collection_search_delegate.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EntrySetActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, EntryEditorMixin, EntryStorageMixin, VaultAwareMixin {
  bool isVisible(
    EntrySetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required int selectedItemCount,
    required bool isTrash,
  }) {
    final canWrite = !settings.isReadOnly;
    final isMain = appMode == AppMode.main;
    final useTvLayout = settings.useTvLayout;
    switch (action) {
      // general
      case .configureView:
        return true;
      case .select:
        return appMode.canSelectMedia && !isSelecting;
      case .selectAll:
        return (isSelecting && selectedItemCount < itemCount) || (!isSelecting && settings.collectionBrowsingQuickActions.contains(action));
      case .selectNone:
        return isSelecting && selectedItemCount == itemCount;
      // browsing
      case .searchCollection:
        return appMode.canNavigate && !isSelecting && !useTvLayout;
      case .toggleTitleSearch:
        return !isSelecting && !useTvLayout;
      case .addShortcut:
        return isMain && !isSelecting && !isTrash && device.canPinShortcut;
      case .addDynamicAlbum:
      case .setHome:
        return isMain && !isSelecting && !isTrash && !useTvLayout;
      case .emptyBin:
        return isMain && isTrash && canWrite;
      // browsing or selecting
      case .map:
      case .slideshow:
      case .stats:
        return isMain;
      case .rescan:
        return isMain && isSelecting && !useTvLayout;
      // selecting
      case .share:
      case .toggleFavourite:
        return isMain && isSelecting && !isTrash;
      case .delete:
        return isMain && isSelecting && canWrite;
      case .copy:
      case .move:
      case .rename:
      case .convert:
      case .exportGpx:
      case .rotateCCW:
      case .rotateCW:
      case .flip:
      case .editDate:
      case .editLocation:
      case .editTitleDescription:
      case .editRating:
      case .editTags:
      case .removeMetadata:
        return isMain && isSelecting && !isTrash && canWrite;
      case .restore:
        return isMain && isSelecting && isTrash && canWrite;
    }
  }

  bool canApply(
    EntrySetAction action, {
    required bool isSelecting,
    required CollectionLens collection,
    required int selectedItemCount,
  }) {
    final itemCount = collection.entryCount;
    final hasItems = itemCount > 0;
    final hasSelection = selectedItemCount > 0;

    switch (action) {
      case .configureView:
        return true;
      case .select:
        return hasItems;
      case .selectAll:
        return selectedItemCount < itemCount || (!isSelecting && settings.collectionBrowsingQuickActions.contains(action));
      case .selectNone:
        return hasSelection;
      case .searchCollection:
      case .toggleTitleSearch:
      case .addShortcut:
      case .setHome:
        return true;
      case .addDynamicAlbum:
        return collection.filters.isNotEmpty;
      case .emptyBin:
        return !isSelecting && hasItems;
      case .map:
      case .slideshow:
      case .stats:
      case .rescan:
        return (!isSelecting && hasItems) || (isSelecting && hasSelection);
      // selecting
      case .share:
      case .delete:
      case .restore:
      case .copy:
      case .move:
      case .rename:
      case .convert:
      case .exportGpx:
      case .toggleFavourite:
      case .rotateCCW:
      case .rotateCW:
      case .flip:
      case .editDate:
      case .editLocation:
      case .editTitleDescription:
      case .editRating:
      case .editTags:
      case .removeMetadata:
        return hasSelection;
    }
  }

  void onActionSelected(BuildContext context, EntrySetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // general
      case .configureView:
      case .select:
      case .selectAll:
      case .selectNone:
        break;
      // browsing
      case .searchCollection:
        _goToSearch(context);
      case .toggleTitleSearch:
        final routeName = context.currentRouteName!;
        settings.setShowTitleQuery(routeName, !settings.getShowTitleQuery(routeName));
        context.read<Query>().toggle();
      case .addDynamicAlbum:
        _addDynamicAlbum(context);
      case .addShortcut:
        _addShortcut(context);
      case .setHome:
        _setHome(context);
      // browsing or selecting
      case .map:
        _goToMap(context);
      case .slideshow:
        _goToSlideshow(context);
      case .stats:
        _goToStats(context);
      case .rescan:
        _rescan(context);
      // selecting
      case .share:
        _share(context);
      case .delete:
      case .emptyBin:
        _delete(context);
      case .restore:
        _move(context, moveType: MoveType.fromBin);
      case .copy:
        _move(context, moveType: MoveType.copy);
      case .move:
        _move(context, moveType: MoveType.move);
      case .rename:
        _rename(context);
      case .convert:
        _convert(context);
      case .exportGpx:
        _exportGpx(context);
      case .toggleFavourite:
        _toggleFavourite(context);
      case .rotateCCW:
        _rotate(context, clockwise: false);
      case .rotateCW:
        _rotate(context, clockwise: true);
      case .flip:
        _flip(context);
      case .editDate:
        editDate(context);
      case .editLocation:
        _editLocation(context);
      case .editTitleDescription:
        _editTitleDescription(context);
      case .editRating:
        _editRating(context);
      case .editTags:
        _editTags(context);
      case .removeMetadata:
        _removeMetadata(context);
    }
  }

  void _browse(BuildContext context) {
    context.read<Selection<AvesEntry>?>()?.browse();
  }

  Set<AvesEntry> _getTargetItems(BuildContext context) {
    final selection = context.read<Selection<AvesEntry>>();
    final groupedEntries = (selection.isSelecting ? selection.selectedItems : context.read<CollectionLens>().sortedEntries);
    return groupedEntries.expand((entry) => entry.stackedEntries ?? {entry}).toSet();
  }

  Future<void> _share(BuildContext context) async {
    final entries = _getTargetItems(context);
    try {
      if (!await appService.shareEntries(entries)) {
        await showNoMatchingAppDialog(context);
      }
    } on TooManyItemsException catch (_) {
      await showWarningDialog(
        context: context,
        message: context.l10n.tooManyItemsErrorDialogMessage,
      );
    }
  }

  void _rescan(BuildContext context) {
    final entries = _getTargetItems(context);

    final controller = AnalysisController(canStartService: true, force: true);
    final collection = context.read<CollectionLens>();
    collection.source.analyze(controller, entries: entries).then((_) => controller.dispose());

    _browse(context);
  }

  Future<void> _delete(BuildContext context) async {
    final entries = _getTargetItems(context);
    final byBinUsage = groupBy<AvesEntry, bool>(entries, (entry) {
      final details = vaults.getVault(entry.directory);
      return details?.useBin ?? settings.enableBin;
    });
    var completed = true;
    await Future.forEach(byBinUsage.entries, (kv) async {
      completed &= await doDelete(
        context: context,
        entries: kv.value.toSet(),
        enableBin: kv.key,
      );
    });

    if (completed) {
      _browse(context);
    }
  }

  // returns whether it completed the action (with or without failures)
  Future<bool> doDelete({
    required BuildContext context,
    required Set<AvesEntry> entries,
    required bool enableBin,
  }) async {
    final pureTrash = entries.every((entry) => entry.trashed);
    if (enableBin && !pureTrash) {
      return await doMove(context, moveType: MoveType.toBin, entries: entries);
    }

    final l10n = context.l10n;
    final source = context.read<CollectionSource>();
    final storageDirs = entries.map((e) => e.storageDirectory).nonNulls.toSet();
    final todoCount = entries.length;

    if (!await showSkippableConfirmationDialog(
      context: context,
      type: ConfirmationDialog.deleteForever,
      message: l10n.deleteEntriesConfirmationDialogMessage(todoCount),
      confirmationButtonLabel: l10n.deleteButtonLabel,
    )) {
      return false;
    }

    if (!await checkStoragePermissionForAlbums(context, storageDirs, entries: entries)) return false;

    source.pauseMonitoring();
    final opId = mediaEditService.newOpId;
    await showOpReport<ImageOpEvent>(
      context: context,
      opStream: mediaEditService.delete(opId: opId, entries: entries),
      itemCount: todoCount,
      onCancel: () => mediaEditService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((op) => op.success).toSet();
        final deletedOps = successOps.where((op) => !op.skipped).toSet();
        final deletedUris = deletedOps.map((op) => op.uri).toSet();
        await source.removeEntries(deletedUris, includeTrash: true);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, FeedbackType.warn, context.l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyRegularDirectories(storageDirs);
      },
    );
    return true;
  }

  Future<void> quickMove(BuildContext context, String destinationAlbum, {required bool copy}) async {
    if (!await unlockAlbum(context, destinationAlbum)) return;

    final entries = _getTargetItems(context);
    final completed = await doQuickMove(
      context,
      moveType: copy ? MoveType.copy : MoveType.move,
      entriesByDestination: {
        destinationAlbum: entries,
      },
    );

    if (completed) {
      _browse(context);
    }
  }

  Future<void> _move(BuildContext context, {required MoveType moveType}) async {
    final entries = _getTargetItems(context);
    final completed = await doMove(context, moveType: moveType, entries: entries);

    if (completed) {
      _browse(context);
    }
  }

  Future<void> _rename(BuildContext context) async {
    final entries = _getTargetItems(context).toList();

    final pattern = await Navigator.maybeOf(context)?.push<NamingPattern>(
      MaterialPageRoute(
        settings: const RouteSettings(name: RenameEntrySetPage.routeName),
        builder: (context) => RenameEntrySetPage(
          entries: entries,
        ),
      ),
    );
    if (pattern == null) return;

    final namingFutures = entries.mapIndexed((index, entry) async {
      final newName = await pattern.apply(entry, index);
      return MapEntry(entry, '$newName${entry.extension}');
    });
    final entriesToNewName = Map.fromEntries(await Future.wait(namingFutures)).whereNotNullValue();
    final completed = await rename(context, entriesToNewName: entriesToNewName, persist: true);

    if (completed) {
      _browse(context);
    }
  }

  Future<void> _convert(BuildContext context) async {
    final entries = _getTargetItems(context);

    final options = await showDialog<EntryConvertOptions>(
      context: context,
      builder: (context) => ConvertEntryDialog(entries: entries),
      routeSettings: const RouteSettings(name: ConvertEntryDialog.routeName),
    );
    if (options == null) return;

    switch (options.action) {
      case .convert:
        final completed = await doExport(context, entries, options);
        if (completed) {
          _browse(context);
        }
      case .convertMotionPhotoToStillImage:
        final todoEntries = entries.where((entry) => entry.isMotionPhoto).toSet();
        await _edit(context, todoEntries, (entry) => entry.removeTrailerVideo());
    }
  }

  Future<void> _exportGpx(BuildContext context) async {
    final entries = _getTargetItems(context).where((entry) => entry.hasGps).sorted(AvesEntrySort.compareByDate).toList();
    if (entries.isEmpty) return;

    final waypoints = entries
        .map((entry) {
          final latLng = entry.latLng;
          return latLng != null
              ? Wpt(
                  lat: latLng.latitude,
                  lon: latLng.longitude,
                  time: entry.bestDate,
                  desc: entry.bestTitle,
                )
              : null;
        })
        .nonNulls
        .toList();
    final bounds = ZoomedBounds.fromPoints(points: waypoints.map((v) => LatLng(v.lat!, v.lon!)).toSet());

    final dateTime = DateTime.now();
    final gpx = Gpx()
      ..creator = device.userAgent
      ..metadata = Metadata(
        author: Person(
          name: device.userAgent,
          link: Link(href: AppReference.avesGithub),
        ),
        time: dateTime,
        bounds: Bounds(
          minlat: bounds.sw.latitude,
          minlon: bounds.sw.longitude,
          maxlat: bounds.ne.latitude,
          maxlon: bounds.ne.longitude,
        ),
      )
      ..wpts = waypoints
      ..rtes = [
        Rte(rtepts: waypoints),
      ]
      ..trks = [
        Trk(
          trksegs: [
            Trkseg(trkpts: waypoints),
          ],
        ),
      ];

    final body = GpxWriter().asString(gpx);
    const mimeType = MimeTypes.gpx;
    final success = await storageService.createFile(
      'aves-gpx-${DateFormat('yyyyMMdd_HHmmss', asciiLocale).format(dateTime)}${MimeTypes.extensionFor(mimeType)}',
      mimeType,
      Uint8List.fromList(utf8.encode(body)),
    );
    if (success != null) {
      if (success) {
        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _toggleFavourite(BuildContext context) async {
    final entries = _getTargetItems(context);
    if (entries.every((entry) => entry.isFavourite)) {
      await favourites.removeEntries(entries);
    } else {
      await favourites.add(entries);
    }

    _browse(context);
  }

  Future<void> _edit(
    BuildContext context,
    Set<AvesEntry> todoEntries,
    Future<Set<EntryDataType>> Function(AvesEntry entry) op, {
    bool shouldCheckUndatedItems = true,
    bool showResult = true,
  }) async {
    final selectionDirs = todoEntries.map((e) => e.directory).nonNulls.toSet();
    final todoCount = todoEntries.length;

    if (!await checkStoragePermissionForAlbums(context, selectionDirs, entries: todoEntries)) return;

    if (shouldCheckUndatedItems && !await checkUndatedItems(context, todoEntries)) return;

    Set<String> obsoleteTags = todoEntries.expand((entry) => entry.tags).toSet();
    Set<String> obsoleteCountryCodes = todoEntries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.countryCode).nonNulls.toSet();
    Set<String> obsoleteStateCodes = todoEntries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.stateCode).nonNulls.toSet();

    final dataTypes = <EntryDataType>{};
    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    var cancelled = false;
    await showOpReport<ImageOpEvent>(
      context: context,
      opStream: Stream.fromIterable(todoEntries).asyncMap((entry) async {
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
        final successOps = processed.where((op) => op.success).toSet();
        final editedOps = successOps.where((op) => !op.skipped).toSet();
        source.resumeMonitoring();

        unawaited(
          source.refreshUris(editedOps.map((op) => op.uri).toSet()).then((_) {
            // invalidate filters derived from values before edition
            // this invalidation must happen after the source is refreshed,
            // otherwise filter chips may eagerly rebuild in between with the old state
            if (obsoleteCountryCodes.isNotEmpty) {
              source.invalidateCountryFilterSummary(countryCodes: obsoleteCountryCodes);
            }
            if (obsoleteStateCodes.isNotEmpty) {
              source.invalidateStateFilterSummary(stateCodes: obsoleteStateCodes);
            }
            if (obsoleteTags.isNotEmpty) {
              source.invalidateTagFilterSummary(tags: obsoleteTags);
            }
          }),
        );

        if (dataTypes.contains(EntryDataType.aspectRatio)) {
          source.onAspectRatioChanged();
        }

        if (showResult) {
          final l10n = context.l10n;
          final successCount = successOps.length;
          if (successCount < todoCount) {
            final count = todoCount - successCount;
            showFeedback(context, FeedbackType.warn, l10n.collectionEditFailureFeedback(count));
          } else {
            final count = editedOps.length;
            showFeedback(context, FeedbackType.info, l10n.collectionEditSuccessFeedback(count));
          }
        }
      },
    );
    _browse(context);
  }

  Future<Set<AvesEntry>?> _getEditableTargetItems(
    BuildContext context, {
    required bool Function(AvesEntry entry) canEdit,
  }) => _getEditableItems(context, _getTargetItems(context), canEdit: canEdit);

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
    final l10n = context.l10n;
    final message = l10n.unsupportedTypeDialogMessage(unsupportedTypes.length, unsupportedTypes.join(', '));
    if (supported.isEmpty) {
      await showWarningDialog(
        context: context,
        message: message,
      );
      return null;
    }

    if (!await showConfirmationDialog(
      context: context,
      message: message,
      ok: l10n.continueButtonLabel,
    )) {
      return null;
    }

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
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

  Future<void> editDate(
    BuildContext context, {
    Set<AvesEntry>? entries,
    DateModifier? modifier,
    bool showResult = true,
  }) async {
    entries ??= await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditDate);
    if (entries == null || entries.isEmpty) return;

    if (modifier == null) {
      final collection = context.read<CollectionLens>();
      modifier = await selectDateModifier(context, entries, collection);
    }
    if (modifier == null) return;

    await _edit(context, entries, (entry) => entry.editDate(modifier!), shouldCheckUndatedItems: false, showResult: showResult);
  }

  Future<void> _editLocation(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditLocation);
    if (entries == null || entries.isEmpty) return;

    final collection = context.read<CollectionLens>();
    final locationByEntry = await selectLocation(context, entries, collection);
    if (locationByEntry == null || locationByEntry.isEmpty) return;

    final todoEntries = locationByEntry.keys.toSet();
    await _edit(context, todoEntries, (entry) => entry.editLocation(locationByEntry[entry]));
  }

  Future<LatLng?> editLocationByMap(BuildContext context, Set<AvesEntry> entries, LatLng clusterLocation, CollectionLens mapCollection) async {
    final todoEntries = await _getEditableItems(context, entries, canEdit: (entry) => entry.canEditLocation);
    if (todoEntries == null || todoEntries.isEmpty) return null;

    final location = await Navigator.maybeOf(context)?.push(
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

    await _edit(context, todoEntries, (entry) => entry.editLocation(location));
    return location;
  }

  Future<void> removeLocation(BuildContext context, Set<AvesEntry> entries) async {
    final l10n = context.l10n;
    if (!await showConfirmationDialog(
      context: context,
      message: l10n.genericDangerWarningDialogMessage,
      ok: l10n.applyButtonLabel,
    )) {
      return;
    }

    final todoEntries = await _getEditableItems(context, entries, canEdit: (entry) => entry.canEditLocation);
    if (todoEntries == null || todoEntries.isEmpty) return;

    await _edit(context, todoEntries, (entry) => entry.editLocation(ExtraAvesEntryMetadataEdition.removalLocation));
  }

  Future<void> _editTitleDescription(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditTitleDescription);
    if (entries == null || entries.isEmpty) return;

    final modifier = await selectTitleDescriptionModifier(context, entries);
    if (modifier == null) return;

    await _edit(context, entries, (entry) => entry.editTitleDescription(modifier));
  }

  Future<void> quickRate(BuildContext context, int rating) => _editRating(context, rating: rating);

  Future<void> _editRating(BuildContext context, {int? rating}) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditRating);
    if (entries == null || entries.isEmpty) return;

    rating ??= await selectRating(context, entries);
    if (rating == null) return;

    await _edit(context, entries, (entry) => entry.editRating(rating));
  }

  Future<void> quickTag(BuildContext context, CollectionFilter filter) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditTags);
    if (entries == null || entries.isEmpty) return;

    final newTagsByEntry = <AvesEntry, Set<String>>{};
    await Future.forEach(entries, (entry) async {
      newTagsByEntry[entry] = {
        ...entry.tags,
        ...await getTagsFromFilters({filter}, entry),
      };
    });

    await _doEditTags(context, newTagsByEntry);
  }

  Future<void> _editTags(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.canEditTags);
    if (entries == null || entries.isEmpty) return;

    final newTagsByEntry = await selectTags(context, entries);
    if (newTagsByEntry == null) return;

    await _doEditTags(context, newTagsByEntry);
  }

  Future<void> _doEditTags(BuildContext context, Map<AvesEntry, Set<String>> newTagsByEntry) async {
    final entries = newTagsByEntry.keys.toSet();

    // only process modified items
    entries.removeWhere((entry) {
      final newTags = newTagsByEntry[entry] ?? entry.tags;
      final currentTags = entry.tags;
      return newTags.length == currentTags.length && newTags.every(currentTags.contains);
    });
    if (entries.isEmpty) return;

    await _edit(context, entries, (entry) => entry.editTags(newTagsByEntry[entry]!));
  }

  Future<void> removeTags(BuildContext context, {required Set<AvesEntry> entries, required Set<String> tags}) async {
    final newTagsByEntry = Map.fromEntries(
      entries.map((v) {
        return MapEntry(v, v.tags.whereNot(tags.contains).toSet());
      }),
    );

    await _edit(context, entries, (entry) => entry.editTags(newTagsByEntry[entry]!));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final entries = await _getEditableTargetItems(context, canEdit: (entry) => entry.isMetadataRemovalSupported);
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
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(collection: mapCollection),
      ),
    );
  }

  void _goToSlideshow(BuildContext context) {
    final collection = context.read<CollectionLens>();
    final entries = _getTargetItems(context);

    Navigator.maybeOf(context)?.push(
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

    Navigator.maybeOf(context)?.push(
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

    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          searchFieldStyle: Themes.searchFieldStyle(context),
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }

  static String? _getDefaultNameForFilters(BuildContext context, Set<CollectionFilter> filters) {
    String? defaultName;
    if (filters.isNotEmpty) {
      // we compute the default name beforehand
      // because some filter labels need localization
      final sortedFilters = List<CollectionFilter>.from(filters)..sort();
      defaultName = sortedFilters.first.getLabel(context).replaceAll('\n', ' ');
    }
    return defaultName;
  }

  Future<void> _addDynamicAlbum(BuildContext context) async {
    final l10n = context.l10n;
    final collection = context.read<CollectionLens>();
    final filters = collection.filters;
    if (filters.isEmpty) return;

    // get navigator beforehand because
    // local context may be deactivated when action is triggered after navigation
    final navigator = Navigator.maybeOf(context);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => const CreateDynamicAlbumDialog(),
      routeSettings: const RouteSettings(name: CreateDynamicAlbumDialog.routeName),
    );
    if (name == null) return;

    final existingAlbum = dynamicAlbums.get(name);
    if (existingAlbum != null) {
      // album already exists, so we just need to highlight it
      await _showDynamicAlbum(navigator, existingAlbum);
    } else {
      final album = DynamicAlbumFilter(name, filters.length == 1 ? filters.first : SetAndFilter(filters));
      await dynamicAlbums.add(album);

      final showAction = SnackBarAction(
        label: l10n.showButtonLabel,
        onPressed: () => _showDynamicAlbum(navigator, album),
      );
      showFeedback(context, FeedbackType.info, l10n.genericSuccessFeedback, showAction);
    }
  }

  Future<void> _showDynamicAlbum(NavigatorState? navigator, DynamicAlbumFilter albumFilter) async {
    // local context may be deactivated when action is triggered after navigation
    if (navigator != null) {
      final context = navigator.context;
      final highlightInfo = context.read<HighlightInfo>();
      if (context.currentRouteName == AlbumListPage.routeName) {
        highlightInfo.trackItem(FilterGridItem(albumFilter, null), highlightItem: albumFilter);
      } else {
        highlightInfo.set(albumFilter);
        final initialGroup = albumGrouping.getFilterParent(albumFilter);
        await navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            settings: const RouteSettings(name: AlbumListPage.routeName),
            builder: (_) => AlbumListPage(initialGroup: initialGroup),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _addShortcut(BuildContext context) async {
    final collection = context.read<CollectionLens>();
    final filters = collection.filters;

    String? defaultName = _getDefaultNameForFilters(context, filters);
    final result = await showDialog<(AvesEntry?, String)>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: defaultName ?? '',
        collection: collection,
      ),
      routeSettings: const RouteSettings(name: AddShortcutDialog.routeName),
    );
    if (result == null) return;

    final (coverEntry, name) = result;
    if (name.isEmpty) return;

    await appService.pinToHomeScreen(name, coverEntry, route: CollectionPage.routeName, filters: filters);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
    }
  }

  void _setHome(BuildContext context) async {
    settings.setHome(HomePageSetting.collection, customCollection: context.read<CollectionLens>().filters);
    showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
  }
}
