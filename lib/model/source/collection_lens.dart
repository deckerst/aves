import 'dart:async';
import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class CollectionLens with ChangeNotifier, CollectionActivityMixin {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  EntryGroupFactor groupFactor;
  EntrySortFactor sortFactor;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier(), sortGroupChangeNotifier = AChangeNotifier();
  int id;
  bool listenToSource;

  List<AvesEntry> _filteredSortedEntries;
  List<StreamSubscription> _subscriptions = [];

  Map<SectionKey, List<AvesEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    @required this.source,
    Iterable<CollectionFilter> filters,
    EntryGroupFactor groupFactor,
    EntrySortFactor sortFactor,
    this.id,
    this.listenToSource = true,
  })  : filters = {if (filters != null) ...filters.where((f) => f != null)},
        groupFactor = groupFactor ?? settings.collectionGroupFactor,
        sortFactor = sortFactor ?? settings.collectionSortFactor {
    id ??= hashCode;
    if (listenToSource) {
      _subscriptions.add(source.eventBus.on<EntryAddedEvent>().listen((e) => onEntryAdded(e.entries)));
      _subscriptions.add(source.eventBus.on<EntryRemovedEvent>().listen((e) => onEntryRemoved(e.entries)));
      _subscriptions.add(source.eventBus.on<EntryMovedEvent>().listen((e) => _refresh()));
      _subscriptions.add(source.eventBus.on<CatalogMetadataChangedEvent>().listen((e) => _refresh()));
      _subscriptions.add(source.eventBus.on<AddressMetadataChangedEvent>().listen((e) {
        if (this.filters.any((filter) => filter is LocationFilter)) {
          _refresh();
        }
      }));
    }
    _refresh();
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _subscriptions = null;
    super.dispose();
  }

  bool get isEmpty => _filteredSortedEntries.isEmpty;

  int get entryCount => _filteredSortedEntries.length;

  // sorted as displayed to the user, i.e. sorted then grouped, not an absolute order on all entries
  List<AvesEntry> _sortedEntries;

  List<AvesEntry> get sortedEntries {
    _sortedEntries ??= List.of(sections.entries.expand((e) => e.value));
    return _sortedEntries;
  }

  bool get showHeaders {
    if (sortFactor == EntrySortFactor.size) return false;

    if (sortFactor == EntrySortFactor.date && groupFactor == EntryGroupFactor.none) return false;

    final albumSections = sortFactor == EntrySortFactor.name || (sortFactor == EntrySortFactor.date && groupFactor == EntryGroupFactor.album);
    final filterByAlbum = filters.any((f) => f is AlbumFilter);
    if (albumSections && filterByAlbum) return false;

    return true;
  }

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
    _refresh();
    filterChangeNotifier.notifyListeners();
  }

  void sort(EntrySortFactor sortFactor) {
    this.sortFactor = sortFactor;
    _applySort();
    _applyGroup();
    sortGroupChangeNotifier.notifyListeners();
  }

  void group(EntryGroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    _applyGroup();
    sortGroupChangeNotifier.notifyListeners();
  }

  void _applyFilters() {
    final entries = source.visibleEntries;
    _filteredSortedEntries = List.of(filters.isEmpty ? entries : entries.where((entry) => filters.fold(true, (prev, filter) => prev && filter.filter(entry))));
  }

  void _applySort() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        _filteredSortedEntries.sort(AvesEntry.compareByDate);
        break;
      case EntrySortFactor.size:
        _filteredSortedEntries.sort(AvesEntry.compareBySize);
        break;
      case EntrySortFactor.name:
        _filteredSortedEntries.sort(AvesEntry.compareByName);
        break;
    }
  }

  void _applyGroup() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        switch (groupFactor) {
          case EntryGroupFactor.album:
            sections = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
            break;
          case EntryGroupFactor.month:
            sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.monthTaken));
            break;
          case EntryGroupFactor.day:
            sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.dayTaken));
            break;
          case EntryGroupFactor.none:
            sections = Map.fromEntries([
              MapEntry(null, _filteredSortedEntries),
            ]);
            break;
        }
        break;
      case EntrySortFactor.size:
        sections = Map.fromEntries([
          MapEntry(null, _filteredSortedEntries),
        ]);
        break;
      case EntrySortFactor.name:
        final byAlbum = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
        sections = SplayTreeMap<EntryAlbumSectionKey, List<AvesEntry>>.of(byAlbum, (a, b) => source.compareAlbumsByName(a.directory, b.directory));
        break;
    }
    sections = Map.unmodifiable(sections);
    _sortedEntries = null;
    notifyListeners();
  }

  // metadata change should also trigger a full refresh
  // as dates impact sorting and grouping
  void _refresh() {
    _applyFilters();
    _applySort();
    _applyGroup();
  }

  void onEntryAdded(Set<AvesEntry> entries) {
    _refresh();
  }

  void onEntryRemoved(Set<AvesEntry> entries) {
    // we should remove obsolete entries and sections
    // but do not apply sort/group
    // as section order change would surprise the user while browsing
    _filteredSortedEntries.removeWhere(entries.contains);
    _sortedEntries?.removeWhere(entries.contains);
    sections.forEach((key, sectionEntries) => sectionEntries.removeWhere(entries.contains));
    sections = Map.unmodifiable(Map.fromEntries(sections.entries.where((kv) => kv.value.isNotEmpty)));
    selection.removeAll(entries);
    notifyListeners();
  }
}

mixin CollectionActivityMixin {
  final ValueNotifier<Activity> _activityNotifier = ValueNotifier(Activity.browse);

  ValueNotifier<Activity> get activityNotifier => _activityNotifier;

  bool get isBrowsing => _activityNotifier.value == Activity.browse;

  bool get isSelecting => _activityNotifier.value == Activity.select;

  void browse() {
    clearSelection();
    _activityNotifier.value = Activity.browse;
  }

  void select() => _activityNotifier.value = Activity.select;

  // selection

  final AChangeNotifier selectionChangeNotifier = AChangeNotifier();

  final Set<AvesEntry> _selection = {};

  Set<AvesEntry> get selection => _selection;

  bool isSelected(Iterable<AvesEntry> entries) => entries.every(selection.contains);

  void addToSelection(Iterable<AvesEntry> entries) {
    _selection.addAll(entries);
    selectionChangeNotifier.notifyListeners();
  }

  void removeFromSelection(Iterable<AvesEntry> entries) {
    _selection.removeAll(entries);
    selectionChangeNotifier.notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    selectionChangeNotifier.notifyListeners();
  }

  void toggleSelection(AvesEntry entry) {
    if (_selection.isEmpty) select();
    if (!_selection.remove(entry)) _selection.add(entry);
    selectionChangeNotifier.notifyListeners();
  }
}
