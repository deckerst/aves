import 'dart:async';
import 'dart:collection';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class CollectionLens with ChangeNotifier, CollectionActivityMixin, CollectionSelectionMixin {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  EntryGroupFactor groupFactor;
  EntrySortFactor sortFactor;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier();

  List<ImageEntry> _filteredEntries;
  List<StreamSubscription> _subscriptions = [];

  Map<dynamic, List<ImageEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    @required this.source,
    Iterable<CollectionFilter> filters,
    @required EntryGroupFactor groupFactor,
    @required EntrySortFactor sortFactor,
  })  : filters = {if (filters != null) ...filters.where((f) => f != null)},
        groupFactor = groupFactor ?? EntryGroupFactor.month,
        sortFactor = sortFactor ?? EntrySortFactor.date {
    _subscriptions.add(source.eventBus.on<EntryAddedEvent>().listen((e) => _refresh()));
    _subscriptions.add(source.eventBus.on<EntryRemovedEvent>().listen((e) => onEntryRemoved(e.entries)));
    _subscriptions.add(source.eventBus.on<EntryMovedEvent>().listen((e) => _refresh()));
    _subscriptions.add(source.eventBus.on<CatalogMetadataChangedEvent>().listen((e) => _refresh()));
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

  // sorted as displayed to the user, i.e. sorted then grouped, not an absolute order on all entries
  List<ImageEntry> _sortedEntries;

  List<ImageEntry> get sortedEntries {
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
    _refresh();
    filterChangeNotifier.notifyListeners();
  }

  void sort(EntrySortFactor sortFactor) {
    this.sortFactor = sortFactor;
    _applySort();
    _applyGroup();
  }

  void group(EntryGroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    _applyGroup();
  }

  void _applyFilters() {
    final rawEntries = source.rawEntries;
    _filteredEntries = List.of(filters.isEmpty ? rawEntries : rawEntries.where((entry) => filters.fold(true, (prev, filter) => prev && filter.filter(entry))));
  }

  void _applySort() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        _filteredEntries.sort(ImageEntry.compareByDate);
        break;
      case EntrySortFactor.size:
        _filteredEntries.sort(ImageEntry.compareBySize);
        break;
      case EntrySortFactor.name:
        _filteredEntries.sort(ImageEntry.compareByName);
        break;
    }
  }

  void _applyGroup() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        switch (groupFactor) {
          case EntryGroupFactor.album:
            sections = groupBy<ImageEntry, String>(_filteredEntries, (entry) => entry.directory);
            break;
          case EntryGroupFactor.month:
            sections = groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.monthTaken);
            break;
          case EntryGroupFactor.day:
            sections = groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.dayTaken);
            break;
          case EntryGroupFactor.none:
            sections = Map.fromEntries([
              MapEntry(null, _filteredEntries),
            ]);
            break;
        }
        break;
      case EntrySortFactor.size:
        sections = Map.fromEntries([
          MapEntry(null, _filteredEntries),
        ]);
        break;
      case EntrySortFactor.name:
        final byAlbum = groupBy<ImageEntry, String>(_filteredEntries, (entry) => entry.directory);
        sections = SplayTreeMap<String, List<ImageEntry>>.of(byAlbum, source.compareAlbumsByName);
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

  void onEntryRemoved(Iterable<ImageEntry> entries) {
    // we should remove obsolete entries and sections
    // but do not apply sort/group
    // as section order change would surprise the user while browsing
    _filteredEntries.removeWhere(entries.contains);
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

  void browse() => _activityNotifier.value = Activity.browse;

  void select() => _activityNotifier.value = Activity.select;
}

mixin CollectionSelectionMixin on CollectionActivityMixin {
  final AChangeNotifier selectionChangeNotifier = AChangeNotifier();

  final Set<ImageEntry> _selection = {};

  Set<ImageEntry> get selection => _selection;

  bool isSelected(Iterable<ImageEntry> entries) => entries.every(selection.contains);

  void addToSelection(Iterable<ImageEntry> entries) {
    _selection.addAll(entries);
    selectionChangeNotifier.notifyListeners();
  }

  void removeFromSelection(Iterable<ImageEntry> entries) {
    _selection.removeAll(entries);
    selectionChangeNotifier.notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    selectionChangeNotifier.notifyListeners();
  }

  void toggleSelection(ImageEntry entry) {
    if (_selection.isEmpty) select();
    if (!_selection.remove(entry)) _selection.add(entry);
    selectionChangeNotifier.notifyListeners();
  }
}
