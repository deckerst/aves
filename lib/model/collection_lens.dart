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
  })  : this.filters = filters ?? [],
        this.groupFactor = groupFactor ?? GroupFactor.month,
        this.sortFactor = sortFactor ?? SortFactor.date {
    _subscriptions.add(source.eventBus.on<EntryAddedEvent>().listen((e) => onSourceChanged()));
    _subscriptions.add(source.eventBus.on<EntryRemovedEvent>().listen((e) => onSourceChanged()));
    _subscriptions.add(source.eventBus.on<MetadataChangedEvent>().listen((e) => onMetadataChanged()));
    onSourceChanged();
  }

  factory CollectionLens.empty() {
    return CollectionLens(
      source: CollectionSource(),
    );
  }

  factory CollectionLens.from(CollectionLens lens, CollectionFilter filter) {
    return CollectionLens(
      source: lens.source,
      filters: [...lens.filters, filter],
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

  void sort(SortFactor sortFactor) {
    this.sortFactor = sortFactor;
    updateSections();
  }

  void group(GroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    updateSections();
  }

  void updateSections() {
    _applySort();
    switch (sortFactor) {
      case SortFactor.date:
        switch (groupFactor) {
          case GroupFactor.album:
            sections = Map.unmodifiable(groupBy(_filteredEntries, (entry) => entry.directory));
            break;
          case GroupFactor.month:
            sections = Map.unmodifiable(groupBy(_filteredEntries, (entry) => entry.monthTaken));
            break;
          case GroupFactor.day:
            sections = Map.unmodifiable(groupBy(_filteredEntries, (entry) => entry.dayTaken));
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
        sections = Map.unmodifiable(SplayTreeMap.from(byAlbum, compare));
        break;
    }
    notifyListeners();
  }

  void _applySort() {
    switch (sortFactor) {
      case SortFactor.date:
        _filteredEntries.sort((a, b) => b.bestDate.compareTo(a.bestDate));
        break;
      case SortFactor.size:
        _filteredEntries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case SortFactor.name:
        _filteredEntries.sort((a, b) => compareAsciiUpperCase(a.title, b.title));
        break;
    }
  }

//  void add(ImageEntry entry) => _rawEntries.add(entry);
//
//  Future<bool> delete(ImageEntry entry) async {
//    final success = await ImageFileService.delete(entry);
//    if (success) {
//      _rawEntries.remove(entry);
//      updateSections();
//    }
//    return success;
//  }

  void onSourceChanged() {
    _applyFilters();
    updateSections();
  }

  void _applyFilters() {
    final rawEntries = source.entries;
    _filteredEntries = List.of(filters.isEmpty ? rawEntries : rawEntries.where((entry) => filters.fold(true, (prev, filter) => prev && filter.filter(entry))));
    updateSections();
  }

  void onMetadataChanged() {
    _applyFilters();
    // metadata dates impact sorting and grouping
    updateSections();
  }
}

enum SortFactor { date, size, name }

enum GroupFactor { album, month, day }
