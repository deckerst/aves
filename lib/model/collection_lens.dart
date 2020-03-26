import 'dart:async';
import 'dart:collection';

import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/image_entry.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CollectionLens with ChangeNotifier {
  final CollectionSource source;
  final List<CollectionFilter> filters;
  GroupFactor groupFactor;
  SortFactor sortFactor;

  List<ImageEntry> _filteredEntries;
  List<StreamSubscription> _subscriptions = [];

  Map<dynamic, List<ImageEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    @required this.source,
    List<CollectionFilter> filters,
    GroupFactor groupFactor,
    SortFactor sortFactor,
  })  : this.filters = [if (filters != null) ...filters.where((f) => f != null)],
        this.groupFactor = groupFactor ?? GroupFactor.month,
        this.sortFactor = sortFactor ?? SortFactor.date {
    _subscriptions.add(source.eventBus.on<EntryAddedEvent>().listen((e) => onEntryAdded()));
    _subscriptions.add(source.eventBus.on<EntryRemovedEvent>().listen((e) => onEntryRemoved(e.entry)));
    _subscriptions.add(source.eventBus.on<CatalogMetadataChangedEvent>().listen((e) => onMetadataChanged()));
    onEntryAdded();
  }

  factory CollectionLens.empty() {
    return CollectionLens(
      source: CollectionSource(),
    );
  }

  factory CollectionLens.from(CollectionLens lens, CollectionFilter filter) {
    if (lens == null) return null;
    return CollectionLens(
      source: lens.source,
      filters: [
        ...lens.filters,
        if (filter != null) filter,
      ],
      groupFactor: lens.groupFactor,
      sortFactor: lens.sortFactor,
    );
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _subscriptions = null;
    super.dispose();
  }

  bool get isEmpty => _filteredEntries.isEmpty;

  int get imageCount => _filteredEntries.where((entry) => !entry.isVideo).length;

  int get videoCount => _filteredEntries.where((entry) => entry.isVideo).length;

  List<ImageEntry> get sortedEntries => List.unmodifiable(sections.entries.expand((e) => e.value));

  Object heroTag(ImageEntry entry) => '$hashCode${entry.uri}';

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
