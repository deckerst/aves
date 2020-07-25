import 'dart:async';
import 'dart:collection';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CollectionLens with ChangeNotifier, CollectionActivityMixin, CollectionSelectionMixin {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  GroupFactor groupFactor;
  SortFactor sortFactor;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier();
  final StreamController<ImageEntry> _highlightController = StreamController.broadcast();

  List<ImageEntry> _filteredEntries;
  List<StreamSubscription> _subscriptions = [];

  Map<dynamic, List<ImageEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    @required this.source,
    Iterable<CollectionFilter> filters,
    @required GroupFactor groupFactor,
    @required SortFactor sortFactor,
  })  : filters = {if (filters != null) ...filters.where((f) => f != null)},
        groupFactor = groupFactor ?? GroupFactor.month,
        sortFactor = sortFactor ?? SortFactor.date {
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

  // sorted as displayed to the user, i.e. sorted then grouped, not an absolute order on all entries
  List<ImageEntry> _sortedEntries;

  List<ImageEntry> get sortedEntries {
    _sortedEntries ??= List.of(sections.entries.expand((e) => e.value));
    return _sortedEntries;
  }

  Stream<ImageEntry> get highlightStream => _highlightController.stream;

  void highlight(ImageEntry entry) => _highlightController.add(entry);

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
    _refresh();
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
    final rawEntries = source.rawEntries;
    _filteredEntries = List.of(filters.isEmpty ? rawEntries : rawEntries.where((entry) => filters.fold(true, (prev, filter) => prev && filter.filter(entry))));
  }

  void _applySort() {
    switch (sortFactor) {
      case SortFactor.date:
        _filteredEntries.sort((a, b) {
          final c = b.bestDate?.compareTo(a.bestDate) ?? -1;
          return c != 0 ? c : compareAsciiUpperCase(a.bestTitle, b.bestTitle);
        });
        break;
      case SortFactor.size:
        _filteredEntries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case SortFactor.name:
        _filteredEntries.sort((a, b) => compareAsciiUpperCase(a.bestTitle, b.bestTitle));
        break;
    }
  }

  void _applyGroup() {
    switch (sortFactor) {
      case SortFactor.date:
        switch (groupFactor) {
          case GroupFactor.album:
            sections = groupBy<ImageEntry, String>(_filteredEntries, (entry) => entry.directory);
            break;
          case GroupFactor.month:
            sections = groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.monthTaken);
            break;
          case GroupFactor.day:
            sections = groupBy<ImageEntry, DateTime>(_filteredEntries, (entry) => entry.dayTaken);
            break;
        }
        break;
      case SortFactor.size:
        sections = Map.fromEntries([
          MapEntry(null, _filteredEntries),
        ]);
        break;
      case SortFactor.name:
        final byAlbum = groupBy<ImageEntry, String>(_filteredEntries, (entry) => entry.directory);
        int compare(a, b) {
          final ua = source.getUniqueAlbumName(a);
          final ub = source.getUniqueAlbumName(b);
          final c = compareAsciiUpperCase(ua, ub);
          if (c != 0) return c;
          final va = androidFileUtils.getStorageVolume(a)?.path ?? '';
          final vb = androidFileUtils.getStorageVolume(b)?.path ?? '';
          return compareAsciiUpperCase(va, vb);
        };
        sections = SplayTreeMap.of(byAlbum, compare);
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

enum SortFactor { date, size, name }

enum GroupFactor { album, month, day }

enum Activity { browse, select }

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
