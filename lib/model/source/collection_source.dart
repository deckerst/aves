import 'dart:async';

import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/model/source/trash.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

enum SourceInitializationState { none, directory, full }

mixin SourceBase {
  EventBus get eventBus;

  Map<int, AvesEntry> get entryById;

  Set<AvesEntry> get visibleEntries;

  Set<AvesEntry> get trashedEntries;

  List<AvesEntry> get sortedEntriesByDate;

  ValueNotifier<SourceState> stateNotifier = ValueNotifier(SourceState.ready);

  ValueNotifier<ProgressEvent> progressNotifier = ValueNotifier(const ProgressEvent(done: 0, total: 0));

  void setProgress({required int done, required int total}) => progressNotifier.value = ProgressEvent(done: done, total: total);
}

abstract class CollectionSource with SourceBase, AlbumMixin, LocationMixin, TagMixin, TrashMixin {
  CollectionSource() {
    settings.updateStream.where((event) => event.key == Settings.localeKey).listen((_) => invalidateAlbumDisplayNames());
    settings.updateStream.where((event) => event.key == Settings.hiddenFiltersKey).listen((event) {
      final oldValue = event.oldValue;
      if (oldValue is List<String>?) {
        final oldHiddenFilters = (oldValue ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();
        _onFilterVisibilityChanged(oldHiddenFilters, settings.hiddenFilters);
      }
    });
  }

  final EventBus _eventBus = EventBus();

  @override
  EventBus get eventBus => _eventBus;

  final Map<int, AvesEntry> _entryById = {};

  @override
  Map<int, AvesEntry> get entryById => Map.unmodifiable(_entryById);

  final Set<AvesEntry> _rawEntries = {};

  Set<AvesEntry> get allEntries => Set.unmodifiable(_rawEntries);

  Set<AvesEntry>? _visibleEntries, _trashedEntries;

  @override
  Set<AvesEntry> get visibleEntries {
    _visibleEntries ??= Set.unmodifiable(_applyHiddenFilters(_rawEntries));
    return _visibleEntries!;
  }

  @override
  Set<AvesEntry> get trashedEntries {
    _trashedEntries ??= Set.unmodifiable(_applyTrashFilter(_rawEntries));
    return _trashedEntries!;
  }

  List<AvesEntry>? _sortedEntriesByDate;

  @override
  List<AvesEntry> get sortedEntriesByDate {
    _sortedEntriesByDate ??= List.unmodifiable(visibleEntries.toList()..sort(AvesEntry.compareByDate));
    return _sortedEntriesByDate!;
  }

  // known date by entry ID
  late Map<int?, int?> _savedDates;

  Future<void> loadDates() async {
    _savedDates = Map.unmodifiable(await metadataDb.loadDates());
  }

  Iterable<AvesEntry> _applyHiddenFilters(Iterable<AvesEntry> entries) {
    final hiddenFilters = {
      TrashFilter.instance,
      ...settings.hiddenFilters,
    };
    return entries.where((entry) => !hiddenFilters.any((filter) => filter.test(entry)));
  }

  Iterable<AvesEntry> _applyTrashFilter(Iterable<AvesEntry> entries) {
    return entries.where(TrashFilter.instance.test);
  }

  void _invalidate([Set<AvesEntry>? entries]) {
    _visibleEntries = null;
    _trashedEntries = null;
    _sortedEntriesByDate = null;
    invalidateAlbumFilterSummary(entries: entries);
    invalidateCountryFilterSummary(entries: entries);
    invalidateTagFilterSummary(entries: entries);
  }

  void updateDerivedFilters([Set<AvesEntry>? entries]) {
    _invalidate(entries);
    // it is possible for entries hidden by a filter type, to have an impact on other types
    // e.g. given a sole entry for country C and tag T, hiding T should make C disappear too
    updateDirectories();
    updateLocations();
    updateTags();
  }

  void addEntries(Set<AvesEntry> entries) {
    if (entries.isEmpty) return;

    final newIdMapEntries = Map.fromEntries(entries.map((entry) => MapEntry(entry.id, entry)));
    if (_rawEntries.isNotEmpty) {
      final newIds = newIdMapEntries.keys.toSet();
      _rawEntries.removeWhere((entry) => newIds.contains(entry.id));
    }

    entries.where((entry) => entry.catalogDateMillis == null).forEach((entry) {
      entry.catalogDateMillis = _savedDates[entry.id];
    });

    _entryById.addAll(newIdMapEntries);
    _rawEntries.addAll(entries);
    _invalidate(entries);

    addDirectories(_applyHiddenFilters(entries).map((entry) => entry.directory).toSet());
    eventBus.fire(EntryAddedEvent(entries));
  }

  Future<void> removeEntries(Set<String> uris, {required bool includeTrash}) async {
    if (uris.isEmpty) return;

    final entries = _rawEntries.where((entry) => uris.contains(entry.uri)).toSet();
    if (!includeTrash) {
      entries.removeWhere(TrashFilter.instance.test);
    }
    if (entries.isEmpty) return;

    final ids = entries.map((entry) => entry.id).toSet();
    await favourites.removeIds(ids);
    await covers.removeIds(ids);
    await metadataDb.removeIds(ids);

    ids.forEach((id) => _entryById.remove);
    _rawEntries.removeAll(entries);
    updateDerivedFilters(entries);
    eventBus.fire(EntryRemovedEvent(entries));
  }

  void clearEntries() {
    _entryById.clear();
    _rawEntries.clear();
    _invalidate();

    // do not update directories/locations/tags here
    // as it could reset filter dependent settings (pins, bookmarks, etc.)
    // caller should take care of updating these at the right time
  }

  Future<void> _moveEntry(AvesEntry entry, Map newFields, {required bool persist}) async {
    newFields.keys.forEach((key) {
      switch (key) {
        case 'contentId':
          entry.contentId = newFields['contentId'] as int?;
          break;
        case 'dateModifiedSecs':
          // `dateModifiedSecs` changes when moving entries to another directory,
          // but it does not change when renaming the containing directory
          entry.dateModifiedSecs = newFields['dateModifiedSecs'] as int?;
          break;
        case 'path':
          entry.path = newFields['path'] as String?;
          break;
        case 'title':
          entry.sourceTitle = newFields['title'] as String?;
          break;
        case 'trashed':
          final trashed = newFields['trashed'] as bool;
          entry.trashed = trashed;
          entry.trashDetails = trashed
              ? TrashDetails(
                  id: entry.id,
                  path: newFields['trashPath'] as String,
                  dateMillis: DateTime.now().millisecondsSinceEpoch,
                )
              : null;
          break;
        case 'uri':
          entry.uri = newFields['uri'] as String;
          break;
      }
    });
    if (entry.trashed) {
      entry.contentId = null;
      entry.uri = 'file://${entry.trashDetails?.path}';
    }

    if (persist) {
      await covers.moveEntry(entry);
      final id = entry.id;
      await metadataDb.updateEntry(id, entry);
      await metadataDb.updateCatalogMetadata(id, entry.catalogMetadata);
      await metadataDb.updateAddress(id, entry.addressDetails);
      await metadataDb.updateTrash(id, entry.trashDetails);
    }
  }

  Future<void> renameAlbum(String sourceAlbum, String destinationAlbum, Set<AvesEntry> entries, Set<MoveOpEvent> movedOps) async {
    final oldFilter = AlbumFilter(sourceAlbum, null);
    final newFilter = AlbumFilter(destinationAlbum, null);

    final bookmark = settings.drawerAlbumBookmarks?.indexOf(sourceAlbum);
    final pinned = settings.pinnedFilters.contains(oldFilter);

    final existingCover = covers.of(oldFilter);
    await covers.set(
      filter: newFilter,
      entryId: existingCover?.item1,
      packageName: existingCover?.item2,
      color: existingCover?.item3,
    );

    renameNewAlbum(sourceAlbum, destinationAlbum);
    await updateAfterMove(
      todoEntries: entries,
      moveType: MoveType.move,
      destinationAlbums: {destinationAlbum},
      movedOps: movedOps,
    );
    // restore bookmark and pin, as the obsolete album got removed and its associated state cleaned
    if (bookmark != null && bookmark != -1) {
      settings.drawerAlbumBookmarks = settings.drawerAlbumBookmarks?..insert(bookmark, destinationAlbum);
    }
    if (pinned) {
      settings.pinnedFilters = settings.pinnedFilters..add(newFilter);
    }
  }

  Future<void> updateAfterMove({
    required Set<AvesEntry> todoEntries,
    required MoveType moveType,
    required Set<String> destinationAlbums,
    required Set<MoveOpEvent> movedOps,
  }) async {
    if (movedOps.isEmpty) return;

    final fromAlbums = <String?>{};
    final movedEntries = <AvesEntry>{};
    final copy = moveType == MoveType.copy;
    if (copy) {
      movedOps.forEach((movedOp) {
        final sourceUri = movedOp.uri;
        final newFields = movedOp.newFields;
        final sourceEntry = todoEntries.firstWhereOrNull((entry) => entry.uri == sourceUri);
        if (sourceEntry != null) {
          fromAlbums.add(sourceEntry.directory);
          movedEntries.add(sourceEntry.copyWith(
            id: metadataDb.nextId,
            uri: newFields['uri'] as String?,
            path: newFields['path'] as String?,
            contentId: newFields['contentId'] as int?,
            // title can change when moved files are automatically renamed to avoid conflict
            title: newFields['title'] as String?,
            dateModifiedSecs: newFields['dateModifiedSecs'] as int?,
          ));
        } else {
          debugPrint('failed to find source entry with uri=$sourceUri');
        }
      });
      await metadataDb.saveEntries(movedEntries);
      await metadataDb.saveCatalogMetadata(movedEntries.map((entry) => entry.catalogMetadata).whereNotNull().toSet());
      await metadataDb.saveAddresses(movedEntries.map((entry) => entry.addressDetails).whereNotNull().toSet());
    } else {
      await Future.forEach<MoveOpEvent>(movedOps, (movedOp) async {
        final newFields = movedOp.newFields;
        if (newFields.isNotEmpty) {
          final sourceUri = movedOp.uri;
          final entry = todoEntries.firstWhereOrNull((entry) => entry.uri == sourceUri);
          if (entry != null) {
            if (moveType == MoveType.fromBin) {
              newFields['trashed'] = false;
            } else {
              fromAlbums.add(entry.directory);
            }
            movedEntries.add(entry);
            await _moveEntry(entry, newFields, persist: true);
          }
        }
      });
    }

    switch (moveType) {
      case MoveType.copy:
        addEntries(movedEntries);
        break;
      case MoveType.move:
      case MoveType.export:
        cleanEmptyAlbums(fromAlbums);
        addDirectories(destinationAlbums);
        break;
      case MoveType.toBin:
      case MoveType.fromBin:
        updateDerivedFilters(movedEntries);
        break;
    }
    invalidateAlbumFilterSummary(directories: fromAlbums);
    _invalidate(movedEntries);
    eventBus.fire(EntryMovedEvent(moveType, movedEntries));
  }

  Future<void> updateAfterRename({
    required Set<AvesEntry> todoEntries,
    required Set<MoveOpEvent> movedOps,
    required bool persist,
  }) async {
    if (movedOps.isEmpty) return;

    final movedEntries = <AvesEntry>{};
    await Future.forEach<MoveOpEvent>(movedOps, (movedOp) async {
      final newFields = movedOp.newFields;
      if (newFields.isNotEmpty) {
        final sourceUri = movedOp.uri;
        final entry = todoEntries.firstWhereOrNull((entry) => entry.uri == sourceUri);
        if (entry != null) {
          movedEntries.add(entry);
          await _moveEntry(entry, newFields, persist: persist);
        }
      }
    });

    eventBus.fire(EntryMovedEvent(MoveType.move, movedEntries));
  }

  SourceInitializationState get initState => SourceInitializationState.none;

  Future<void> init({
    AnalysisController? analysisController,
    String? directory,
    bool loadTopEntriesFirst = false,
  });

  Future<Set<String>> refreshUris(Set<String> changedUris, {AnalysisController? analysisController});

  Future<void> refreshEntry(AvesEntry entry, Set<EntryDataType> dataTypes) async {
    await entry.refresh(background: false, persist: true, dataTypes: dataTypes, geocoderLocale: settings.appliedLocale);

    // update/delete in DB
    final id = entry.id;
    if (dataTypes.contains(EntryDataType.catalog)) {
      await metadataDb.updateCatalogMetadata(id, entry.catalogMetadata);
      onCatalogMetadataChanged();
    }
    if (dataTypes.contains(EntryDataType.address)) {
      await metadataDb.updateAddress(id, entry.addressDetails);
      onAddressMetadataChanged();
    }

    updateDerivedFilters({entry});
    eventBus.fire(EntryRefreshedEvent({entry}));
  }

  Future<void> analyze(AnalysisController? analysisController, {Set<AvesEntry>? entries}) async {
    final todoEntries = entries ?? visibleEntries;
    final _analysisController = analysisController ?? AnalysisController();
    final force = _analysisController.force;
    if (!_analysisController.isStopping) {
      var startAnalysisService = false;
      if (_analysisController.canStartService && settings.canUseAnalysisService) {
        // cataloguing
        if (!startAnalysisService) {
          final opCount = (force ? todoEntries : todoEntries.where(TagMixin.catalogEntriesTest)).length;
          if (opCount > TagMixin.commitCountThreshold) {
            startAnalysisService = true;
          }
        }
        // ignore locating countries
        // locating places
        if (!startAnalysisService && await availability.canLocatePlaces) {
          final opCount = (force ? todoEntries.where((entry) => entry.hasGps) : todoEntries.where(LocationMixin.locatePlacesTest)).length;
          if (opCount > LocationMixin.commitCountThreshold) {
            startAnalysisService = true;
          }
        }
      }
      if (startAnalysisService) {
        await AnalysisService.startService(
          force: force,
          entryIds: entries?.map((entry) => entry.id).toList(),
        );
      } else {
        await catalogEntries(_analysisController, todoEntries);
        updateDerivedFilters(todoEntries);
        await locateEntries(_analysisController, todoEntries);
        updateDerivedFilters(todoEntries);
      }
    }
    stateNotifier.value = SourceState.ready;
  }

  // monitoring

  bool _monitoring = true;

  void pauseMonitoring() => _monitoring = false;

  void resumeMonitoring() => _monitoring = true;

  bool get isMonitoring => _monitoring;

  // filter summary

  int count(CollectionFilter filter) {
    if (filter is AlbumFilter) return albumEntryCount(filter);
    if (filter is LocationFilter) return countryEntryCount(filter);
    if (filter is TagFilter) return tagEntryCount(filter);
    return 0;
  }

  AvesEntry? recentEntry(CollectionFilter filter) {
    if (filter is AlbumFilter) return albumRecentEntry(filter);
    if (filter is LocationFilter) return countryRecentEntry(filter);
    if (filter is TagFilter) return tagRecentEntry(filter);
    return null;
  }

  AvesEntry? coverEntry(CollectionFilter filter) {
    final id = covers.of(filter)?.item1;
    if (id != null) {
      final entry = visibleEntries.firstWhereOrNull((entry) => entry.id == id);
      if (entry != null) return entry;
    }
    return recentEntry(filter);
  }

  void _onFilterVisibilityChanged(Set<CollectionFilter> oldHiddenFilters, Set<CollectionFilter> currentHiddenFilters) {
    updateDerivedFilters();
    eventBus.fire(const FilterVisibilityChangedEvent());

    final newlyVisibleFilters = oldHiddenFilters.whereNot(currentHiddenFilters.contains).toSet();
    if (newlyVisibleFilters.isNotEmpty) {
      final candidateEntries = visibleEntries.where((entry) => newlyVisibleFilters.any((f) => f.test(entry))).toSet();
      analyze(null, entries: candidateEntries);
    }
  }
}
