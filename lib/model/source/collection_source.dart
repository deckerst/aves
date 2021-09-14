import 'dart:async';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

mixin SourceBase {
  EventBus get eventBus;

  Map<int?, AvesEntry> get entryById;

  Set<AvesEntry> get visibleEntries;

  List<AvesEntry> get sortedEntriesByDate;

  ValueNotifier<SourceState> stateNotifier = ValueNotifier(SourceState.ready);

  final StreamController<ProgressEvent> _progressStreamController = StreamController.broadcast();

  Stream<ProgressEvent> get progressStream => _progressStreamController.stream;

  void setProgress({required int done, required int total}) => _progressStreamController.add(ProgressEvent(done: done, total: total));
}

abstract class CollectionSource with SourceBase, AlbumMixin, LocationMixin, TagMixin {
  final EventBus _eventBus = EventBus();

  @override
  EventBus get eventBus => _eventBus;

  final Map<int?, AvesEntry> _entryById = {};

  @override
  Map<int?, AvesEntry> get entryById => Map.unmodifiable(_entryById);

  final Set<AvesEntry> _rawEntries = {};

  Set<AvesEntry> get allEntries => Set.unmodifiable(_rawEntries);

  Set<AvesEntry>? _visibleEntries;

  @override
  Set<AvesEntry> get visibleEntries {
    _visibleEntries ??= Set.unmodifiable(_applyHiddenFilters(_rawEntries));
    return _visibleEntries!;
  }

  List<AvesEntry>? _sortedEntriesByDate;

  @override
  List<AvesEntry> get sortedEntriesByDate {
    _sortedEntriesByDate ??= List.unmodifiable(visibleEntries.toList()..sort(AvesEntry.compareByDate));
    return _sortedEntriesByDate!;
  }

  late Map<int?, int?> _savedDates;

  Future<void> loadDates() async {
    final stopwatch = Stopwatch()..start();
    _savedDates = Map.unmodifiable(await metadataDb.loadDates());
    debugPrint('$runtimeType loadDates complete in ${stopwatch.elapsed.inMilliseconds}ms for ${_savedDates.length} entries');
  }

  Iterable<AvesEntry> _applyHiddenFilters(Iterable<AvesEntry> entries) {
    final hiddenFilters = settings.hiddenFilters;
    return hiddenFilters.isEmpty ? entries : entries.where((entry) => !hiddenFilters.any((filter) => filter.test(entry)));
  }

  void _invalidate([Set<AvesEntry>? entries]) {
    _visibleEntries = null;
    _sortedEntriesByDate = null;
    invalidateAlbumFilterSummary(entries: entries);
    invalidateCountryFilterSummary(entries);
    invalidateTagFilterSummary(entries);
  }

  void addEntries(Set<AvesEntry> entries) {
    if (entries.isEmpty) return;

    final newIdMapEntries = Map.fromEntries(entries.map((v) => MapEntry(v.contentId, v)));
    if (_rawEntries.isNotEmpty) {
      final newContentIds = newIdMapEntries.keys.toSet();
      _rawEntries.removeWhere((entry) => newContentIds.contains(entry.contentId));
    }

    entries.forEach((entry) => entry.catalogDateMillis = _savedDates[entry.contentId]);

    _entryById.addAll(newIdMapEntries);
    _rawEntries.addAll(entries);
    _invalidate(entries);

    addDirectories(_applyHiddenFilters(entries).map((entry) => entry.directory).toSet());
    eventBus.fire(EntryAddedEvent(entries));
  }

  Future<void> removeEntries(Set<String> uris) async {
    if (uris.isEmpty) return;
    final entries = _rawEntries.where((entry) => uris.contains(entry.uri)).toSet();
    await favourites.remove(entries);
    await covers.removeEntries(entries);

    entries.forEach((v) => _entryById.remove(v.contentId));
    _rawEntries.removeAll(entries);
    _invalidate(entries);

    cleanEmptyAlbums(entries.map((entry) => entry.directory).toSet());
    updateLocations();
    updateTags();
    eventBus.fire(EntryRemovedEvent(entries));
  }

  void clearEntries() {
    _entryById.clear();
    _rawEntries.clear();
    _invalidate();

    updateDirectories();
    updateLocations();
    updateTags();
  }

  Future<void> _moveEntry(AvesEntry entry, Map newFields, {required bool persist}) async {
    final oldContentId = entry.contentId!;
    final newContentId = newFields['contentId'] as int?;

    entry.contentId = newContentId;
    // `dateModifiedSecs` changes when moving entries to another directory,
    // but it does not change when renaming the containing directory
    if (newFields.containsKey('dateModifiedSecs')) entry.dateModifiedSecs = newFields['dateModifiedSecs'] as int?;
    if (newFields.containsKey('path')) entry.path = newFields['path'] as String?;
    if (newFields.containsKey('uri')) entry.uri = newFields['uri'] as String;
    if (newFields.containsKey('title')) entry.sourceTitle = newFields['title'] as String?;

    entry.catalogMetadata = entry.catalogMetadata?.copyWith(contentId: newContentId);
    entry.addressDetails = entry.addressDetails?.copyWith(contentId: newContentId);

    if (persist) {
      await metadataDb.updateEntryId(oldContentId, entry);
      await metadataDb.updateMetadataId(oldContentId, entry.catalogMetadata);
      await metadataDb.updateAddressId(oldContentId, entry.addressDetails);
      await favourites.moveEntry(oldContentId, entry);
      await covers.moveEntry(oldContentId, entry);
    }
  }

  Future<bool> renameEntry(AvesEntry entry, String newName, {required bool persist}) async {
    if (newName == entry.filenameWithoutExtension) return true;
    final newFields = await mediaFileService.rename(entry, '$newName${entry.extension}');
    if (newFields.isEmpty) return false;

    await _moveEntry(entry, newFields, persist: persist);
    entry.metadataChangeNotifier.notifyListeners();
    eventBus.fire(EntryMovedEvent({entry}));
    return true;
  }

  Future<void> renameAlbum(String sourceAlbum, String destinationAlbum, Set<AvesEntry> todoEntries, Set<MoveOpEvent> movedOps) async {
    final oldFilter = AlbumFilter(sourceAlbum, null);
    final bookmarked = settings.drawerAlbumBookmarks?.contains(sourceAlbum) == true;
    final pinned = settings.pinnedFilters.contains(oldFilter);
    final oldCoverContentId = covers.coverContentId(oldFilter);
    final coverEntry = oldCoverContentId != null ? todoEntries.firstWhereOrNull((entry) => entry.contentId == oldCoverContentId) : null;
    renameNewAlbum(sourceAlbum, destinationAlbum);
    await updateAfterMove(
      todoEntries: todoEntries,
      copy: false,
      destinationAlbum: destinationAlbum,
      movedOps: movedOps,
    );
    // restore bookmark, pin and cover, as the obsolete album got removed and its associated state cleaned
    final newFilter = AlbumFilter(destinationAlbum, null);
    if (bookmarked) {
      settings.drawerAlbumBookmarks = settings.drawerAlbumBookmarks?..add(destinationAlbum);
    }
    if (pinned) {
      settings.pinnedFilters = settings.pinnedFilters..add(newFilter);
    }
    if (coverEntry != null) {
      await covers.set(newFilter, coverEntry.contentId);
    }
  }

  Future<void> updateAfterMove({
    required Set<AvesEntry> todoEntries,
    required bool copy,
    required String destinationAlbum,
    required Set<MoveOpEvent> movedOps,
  }) async {
    if (movedOps.isEmpty) return;

    final fromAlbums = <String?>{};
    final movedEntries = <AvesEntry>{};
    if (copy) {
      movedOps.forEach((movedOp) {
        final sourceUri = movedOp.uri;
        final newFields = movedOp.newFields;
        final sourceEntry = todoEntries.firstWhereOrNull((entry) => entry.uri == sourceUri);
        if (sourceEntry != null) {
          fromAlbums.add(sourceEntry.directory);
          movedEntries.add(sourceEntry.copyWith(
            uri: newFields['uri'] as String?,
            path: newFields['path'] as String?,
            contentId: newFields['contentId'] as int?,
            dateModifiedSecs: newFields['dateModifiedSecs'] as int?,
          ));
        }
      });
      await metadataDb.saveEntries(movedEntries);
      await metadataDb.saveMetadata(movedEntries.map((entry) => entry.catalogMetadata).whereNotNull().toSet());
      await metadataDb.saveAddresses(movedEntries.map((entry) => entry.addressDetails).whereNotNull().toSet());
    } else {
      await Future.forEach<MoveOpEvent>(movedOps, (movedOp) async {
        final newFields = movedOp.newFields;
        if (newFields.isNotEmpty) {
          final sourceUri = movedOp.uri;
          final entry = todoEntries.firstWhereOrNull((entry) => entry.uri == sourceUri);
          if (entry != null) {
            fromAlbums.add(entry.directory);
            movedEntries.add(entry);
            await _moveEntry(entry, newFields, persist: true);
          }
        }
      });
    }

    if (copy) {
      addEntries(movedEntries);
    } else {
      cleanEmptyAlbums(fromAlbums);
      addDirectories({destinationAlbum});
    }
    invalidateAlbumFilterSummary(directories: fromAlbums);
    _invalidate(movedEntries);
    eventBus.fire(EntryMovedEvent(movedEntries));
  }

  bool get initialized => false;

  Future<void> init();

  Future<void> refresh();

  Future<void> rescan(Set<AvesEntry> entries);

  Future<void> refreshMetadata(Set<AvesEntry> entries) async {
    await Future.forEach<AvesEntry>(entries, (entry) => entry.refresh(persist: true));

    _invalidate(entries);
    updateLocations();
    updateTags();

    eventBus.fire(EntryRefreshedEvent(entries));
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
    final contentId = covers.coverContentId(filter);
    if (contentId != null) {
      final entry = visibleEntries.firstWhereOrNull((entry) => entry.contentId == contentId);
      if (entry != null) return entry;
    }
    return recentEntry(filter);
  }

  void changeFilterVisibility(Set<CollectionFilter> filters, bool visible) {
    final hiddenFilters = settings.hiddenFilters;
    if (visible) {
      hiddenFilters.removeAll(filters);
    } else {
      hiddenFilters.addAll(filters);
      settings.searchHistory = settings.searchHistory..removeWhere(filters.contains);
    }
    settings.hiddenFilters = hiddenFilters;

    _invalidate();
    // it is possible for entries hidden by a filter type, to have an impact on other types
    // e.g. given a sole entry for country C and tag T, hiding T should make C disappear too
    updateDirectories();
    updateLocations();
    updateTags();

    eventBus.fire(FilterVisibilityChangedEvent(filters, visible));

    if (visible) {
      refreshMetadata(visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet());
    }
  }
}

class EntryAddedEvent {
  final Set<AvesEntry>? entries;

  const EntryAddedEvent([this.entries]);
}

class EntryRemovedEvent {
  final Set<AvesEntry> entries;

  const EntryRemovedEvent(this.entries);
}

class EntryMovedEvent {
  final Set<AvesEntry> entries;

  const EntryMovedEvent(this.entries);
}

class EntryRefreshedEvent {
  final Set<AvesEntry> entries;

  const EntryRefreshedEvent(this.entries);
}

class FilterVisibilityChangedEvent {
  final Set<CollectionFilter> filters;
  final bool visible;

  const FilterVisibilityChangedEvent(this.filters, this.visible);
}

class ProgressEvent {
  final int done, total;

  const ProgressEvent({required this.done, required this.total});
}
