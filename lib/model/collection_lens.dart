import 'dart:async';
import 'dart:collection';

import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CollectionLens with ChangeNotifier {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  GroupFactor groupFactor;
  SortFactor sortFactor;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier();

  List<ImageEntry> _filteredEntries;
  List<StreamSubscription> _subscriptions = [];

  Map<dynamic, List<ImageEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    @required this.source,
    Iterable<CollectionFilter> filters,
    @required GroupFactor groupFactor,
    @required SortFactor sortFactor,
  })  : this.filters = [if (filters != null) ...filters.where((f) => f != null)].toSet(),
        this.groupFactor = groupFactor ?? GroupFactor.month,
        this.sortFactor = sortFactor ?? SortFactor.date {
    _subscriptions.add(source.eventBus.on<EntryAddedEvent>().listen((e) => onEntryAdded()));
    _subscriptions.add(source.eventBus.on<EntryRemovedEvent>().listen((e) => onEntryRemoved(e.entry)));
    _subscriptions.add(source.eventBus.on<CatalogMetadataChangedEvent>().listen((e) => onMetadataChanged()));
    onEntryAdded();
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _subscriptions = null;
    super.dispose();
  }

  factory CollectionLens.empty() {
    return CollectionLens(
      source: CollectionSource(),
      groupFactor: settings.collectionGroupFactor,
      sortFactor: settings.collectionSortFactor,
    );
  }

  CollectionLens derive(CollectionFilter filter) {
    return CollectionLens(
      source: source,
      filters: filters,
      groupFactor: groupFactor,
      sortFactor: sortFactor,
    )..addFilter(filter);
  }

  bool get isEmpty => _filteredEntries.isEmpty;

  int get entryCount => _filteredEntries.length;

  List<ImageEntry> _sortedEntries;

  List<ImageEntry> get sortedEntries {
    if (_sortedEntries == null) {
      _sortedEntries = List.of(sections.entries.expand((e) => e.value));
    }
    return _sortedEntries;
  }

  bool get showHeaders {
    if (sortFactor == SortFactor.size) return false;

    final albumSections = sortFactor == SortFactor.name || (sortFactor == SortFactor.date && groupFactor == GroupFactor.album);
    final filterByAlbum = filters.any((f) => f is AlbumFilter);
    if (albumSections && filterByAlbum) return false;

    return true;
  }

  Object heroTag(ImageEntry entry) => '$hashCode${entry.uri}';

  void addFilter(CollectionFilter filter) {
    if (filter == null || filters.contains(filter)) return;
    if (filter.isUnique) {
      filters.removeWhere((old) => old.typeKey == filter.typeKey);
    }
    filters.add(filter);
    onFilterChanged();
  }

  void removeFilter(CollectionFilter filter) {
    if (filter == null || !filters.contains(filter)) return;
    filters.remove(filter);
    onFilterChanged();
  }

  void onFilterChanged() {
    _applyFilters();
    _applySort();
    _applyGroup();
    filterChangeNotifier.notifyListeners();
  }

  void sort(SortFactor sortFactor) {
    this.sortFactor = sortFactor;
    _applySort();
    _applyGroup();
  }

  void group(GroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    _applyGroup();
  }

  void _applyFilters() {
    final rawEntries = source.entries;
    _filteredEntries = List.of(filters.isEmpty ? rawEntries : rawEntries.where((entry) => filters.fold(true, (prev, filter) => prev && filter.filter(entry))));
  }

  void _applySort() {
    switch (sortFactor) {
      case SortFactor.date:
        _filteredEntries.sort((a, b) {
          final c = b.bestDate.compareTo(a.bestDate);
          return c != 0 ? c : compareAsciiUpperCase(a.title, b.title);
        });
        break;
      case SortFactor.size:
        _filteredEntries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case SortFactor.name:
        _filteredEntries.sort((a, b) => compareAsciiUpperCase(a.title, b.title));
        break;
    }
  }

  void _applyGroup() {
    switch (sortFactor) {
      case SortFactor.date:
        switch (groupFactor) {
          case GroupFactor.album:
            sections = Map.unmodifiable(groupBy<ImageEntry, String>(_filteredEntries, (entry) => entry.directory));
            break;
          case GroupFactor.month:
            sections = Map.unmodifiable(groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.monthTaken));
            break;
          case GroupFactor.day:
            sections = Map.unmodifiable(groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.dayTaken));
            break;
        }
        break;
      case SortFactor.size:
        sections = Map.unmodifiable(Map.fromEntries([
          MapEntry(null, _filteredEntries),
        ]));
        break;
      case SortFactor.name:
        final byAlbum = groupBy(_filteredEntries, (ImageEntry entry) => entry.directory);
        final albums = byAlbum.keys.toSet();
        final compare = (a, b) {
          final ua = CollectionSource.getUniqueAlbumName(a, albums);
          final ub = CollectionSource.getUniqueAlbumName(b, albums);
          return compareAsciiUpperCase(ua, ub);
        };
        sections = Map.unmodifiable(SplayTreeMap.of(byAlbum, compare));
        break;
    }
    _sortedEntries = null;
    notifyListeners();
  }

  void onEntryAdded() {
    _applyFilters();
    _applySort();
    _applyGroup();
  }

  void onEntryRemoved(ImageEntry entry) {
    // do not apply sort/group as section order change would surprise the user while browsing
    _filteredEntries.remove(entry);
    _sortedEntries?.remove(entry);
    sections.forEach((key, entries) => entries.remove(entry));
    notifyListeners();
  }

  void onMetadataChanged() {
    _applyFilters();
    // metadata dates impact sorting and grouping
    _applySort();
    _applyGroup();
  }
}

enum SortFactor { date, size, name }

enum GroupFactor { album, month, day }
