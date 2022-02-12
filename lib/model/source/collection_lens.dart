import 'dart:async';
import 'dart:collection';

import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class CollectionLens with ChangeNotifier {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  EntryGroupFactor sectionFactor;
  EntrySortFactor sortFactor;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier(), sortSectionChangeNotifier = AChangeNotifier();
  final List<StreamSubscription> _subscriptions = [];
  int? id;
  bool listenToSource;
  List<AvesEntry>? fixedSelection;

  List<AvesEntry> _filteredSortedEntries = [];

  Map<SectionKey, List<AvesEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    required this.source,
    Set<CollectionFilter?>? filters,
    this.id,
    this.listenToSource = true,
    this.fixedSelection,
  })  : filters = (filters ?? {}).whereNotNull().toSet(),
        sectionFactor = settings.collectionSectionFactor,
        sortFactor = settings.collectionSortFactor {
    id ??= hashCode;
    if (listenToSource) {
      final sourceEvents = source.eventBus;
      _subscriptions.add(sourceEvents.on<EntryAddedEvent>().listen((e) => _onEntryAdded(e.entries)));
      _subscriptions.add(sourceEvents.on<EntryRemovedEvent>().listen((e) => _onEntryRemoved(e.entries)));
      _subscriptions.add(sourceEvents.on<EntryMovedEvent>().listen((e) {
        if (e.type == MoveType.move) {
          // refreshing copied items is already handled via `EntryAddedEvent`s
          _refresh();
        }
      }));
      _subscriptions.add(sourceEvents.on<EntryRefreshedEvent>().listen((e) => _refresh()));
      _subscriptions.add(sourceEvents.on<FilterVisibilityChangedEvent>().listen((e) => _refresh()));
      _subscriptions.add(sourceEvents.on<CatalogMetadataChangedEvent>().listen((e) => _refresh()));
      _subscriptions.add(sourceEvents.on<AddressMetadataChangedEvent>().listen((e) {
        if (this.filters.any((filter) => filter is LocationFilter)) {
          _refresh();
        }
      }));
      favourites.addListener(_onFavouritesChanged);
    }
    _subscriptions.add(settings.updateStream
        .where([
          Settings.collectionSortFactorKey,
          Settings.collectionGroupFactorKey,
        ].contains)
        .listen((_) => _onSettingsChanged()));
    _refresh();
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    favourites.removeListener(_onFavouritesChanged);
    super.dispose();
  }

  CollectionLens copyWith({
    CollectionSource? source,
    Set<CollectionFilter>? filters,
    bool? listenToSource,
    List<AvesEntry>? fixedSelection,
  }) =>
      CollectionLens(
        source: source ?? this.source,
        filters: filters ?? this.filters,
        id: id,
        listenToSource: listenToSource ?? this.listenToSource,
        fixedSelection: fixedSelection ?? this.fixedSelection,
      );

  bool get isEmpty => _filteredSortedEntries.isEmpty;

  int get entryCount => _filteredSortedEntries.length;

  // sorted as displayed to the user, i.e. sorted then sectioned, not an absolute order on all entries
  List<AvesEntry>? _sortedEntries;

  List<AvesEntry> get sortedEntries {
    _sortedEntries ??= List.of(sections.entries.expand((kv) => kv.value));
    return _sortedEntries!;
  }

  bool get showHeaders {
    bool showAlbumHeaders() => !filters.any((f) => f is AlbumFilter);

    switch (sortFactor) {
      case EntrySortFactor.date:
        switch (sectionFactor) {
          case EntryGroupFactor.none:
            return false;
          case EntryGroupFactor.album:
            return showAlbumHeaders();
          case EntryGroupFactor.month:
            return true;
          case EntryGroupFactor.day:
            return true;
        }
      case EntrySortFactor.name:
        return showAlbumHeaders();
      case EntrySortFactor.rating:
        return !filters.any((f) => f is RatingFilter);
      case EntrySortFactor.size:
        return false;
    }
  }

  void addFilter(CollectionFilter filter) {
    if (filters.contains(filter)) return;
    if (filter.isUnique) {
      filters.removeWhere((old) => old.category == filter.category);
    }
    filters.add(filter);
    _onFilterChanged();
  }

  void removeFilter(CollectionFilter filter) {
    if (!filters.contains(filter)) return;
    filters.remove(filter);
    _onFilterChanged();
  }

  void setLiveQuery(String query) {
    filters.removeWhere((v) => v is QueryFilter && v.live);
    if (query.isNotEmpty) {
      filters.add(QueryFilter(query, live: true));
    }
    _onFilterChanged();
  }

  void _onFilterChanged() {
    _refresh();
    filterChangeNotifier.notifyListeners();
  }

  final bool groupBursts = true;

  void _applyFilters() {
    final entries = fixedSelection ?? source.visibleEntries;
    _filteredSortedEntries = List.of(filters.isEmpty ? entries : entries.where((entry) => filters.every((filter) => filter.test(entry))));

    if (groupBursts) {
      _groupBursts();
    }
  }

  void _groupBursts() {
    final byBurstKey = groupBy<AvesEntry, String?>(_filteredSortedEntries, (entry) => entry.burstKey).whereNotNullKey();
    byBurstKey.forEach((burstKey, entries) {
      if (entries.length > 1) {
        entries.sort(AvesEntry.compareByName);
        final mainEntry = entries.first;
        final burstEntry = mainEntry.copyWith(burstEntries: entries);

        entries.skip(1).toList().forEach((subEntry) {
          _filteredSortedEntries.remove(subEntry);
        });
        final index = _filteredSortedEntries.indexOf(mainEntry);
        _filteredSortedEntries.removeAt(index);
        _filteredSortedEntries.insert(index, burstEntry);
      }
    });
  }

  void _applySort() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        _filteredSortedEntries.sort(AvesEntry.compareByDate);
        break;
      case EntrySortFactor.name:
        _filteredSortedEntries.sort(AvesEntry.compareByName);
        break;
      case EntrySortFactor.rating:
        _filteredSortedEntries.sort(AvesEntry.compareByRating);
        break;
      case EntrySortFactor.size:
        _filteredSortedEntries.sort(AvesEntry.compareBySize);
        break;
    }
  }

  void _applySection() {
    switch (sortFactor) {
      case EntrySortFactor.date:
        switch (sectionFactor) {
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
              MapEntry(const SectionKey(), _filteredSortedEntries),
            ]);
            break;
        }
        break;
      case EntrySortFactor.name:
        final byAlbum = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
        sections = SplayTreeMap<EntryAlbumSectionKey, List<AvesEntry>>.of(byAlbum, (a, b) => source.compareAlbumsByName(a.directory!, b.directory!));
        break;
      case EntrySortFactor.rating:
        sections = groupBy<AvesEntry, EntryRatingSectionKey>(_filteredSortedEntries, (entry) => EntryRatingSectionKey(entry.rating));
        break;
      case EntrySortFactor.size:
        sections = Map.fromEntries([
          MapEntry(const SectionKey(), _filteredSortedEntries),
        ]);
        break;
    }
    sections = Map.unmodifiable(sections);
    _sortedEntries = null;
    notifyListeners();
  }

  // metadata change should also trigger a full refresh
  // as dates impact sorting and sectioning
  void _refresh() {
    _applyFilters();
    _applySort();
    _applySection();
  }

  void _onFavouritesChanged() {
    if (filters.any((filter) => filter is FavouriteFilter)) {
      _refresh();
    }
  }

  void _onSettingsChanged() {
    final newSortFactor = settings.collectionSortFactor;
    final newSectionFactor = settings.collectionSectionFactor;

    final needSort = sortFactor != newSortFactor;
    final needSection = needSort || sectionFactor != newSectionFactor;

    if (needSort) {
      sortFactor = newSortFactor;
      _applySort();
    }
    if (needSection) {
      sectionFactor = newSectionFactor;
      _applySection();
    }
    if (needSort || needSection) {
      sortSectionChangeNotifier.notifyListeners();
    }
  }

  void _onEntryAdded(Set<AvesEntry>? entries) {
    _refresh();
  }

  void _onEntryRemoved(Set<AvesEntry> entries) {
    if (groupBursts) {
      // find impacted burst groups
      final obsoleteBurstEntries = <AvesEntry>{};
      final burstKeys = entries.map((entry) => entry.burstKey).whereNotNull().toSet();
      if (burstKeys.isNotEmpty) {
        _filteredSortedEntries.where((entry) => entry.isBurst && burstKeys.contains(entry.burstKey)).forEach((mainEntry) {
          final subEntries = mainEntry.burstEntries!;
          // remove the deleted sub-entries
          subEntries.removeWhere(entries.contains);
          if (subEntries.isEmpty) {
            // remove the burst entry itself
            obsoleteBurstEntries.add(mainEntry);
          }
          // TODO TLAD [burst] recreate the burst main entry if the first sub-entry got deleted
        });
        entries.addAll(obsoleteBurstEntries);
      }
    }

    // we should remove obsolete entries and sections
    // but do not apply sort/section
    // as section order change would surprise the user while browsing
    fixedSelection?.removeWhere(entries.contains);
    _filteredSortedEntries.removeWhere(entries.contains);
    _sortedEntries?.removeWhere(entries.contains);
    sections.forEach((key, sectionEntries) => sectionEntries.removeWhere(entries.contains));
    sections = Map.unmodifiable(Map.fromEntries(sections.entries.where((kv) => kv.value.isNotEmpty)));
    notifyListeners();
  }
}
