import 'dart:async';
import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/model/source/location/location.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CollectionLens with ChangeNotifier {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  List<String> burstPatterns;
  EntrySectionFactor sectionFactor;
  EntrySortFactor sortFactor;
  bool sortReverse;
  final AChangeNotifier filterChangeNotifier = .new();
  final AChangeNotifier layoutChangeNotifier = .new();
  final Set<StreamSubscription> _subscriptions = {};
  int? id;
  bool listenToSource, stackBursts, stackDevelopedRaws, fixedSort;
  List<AvesEntry>? fixedSelection;

  // temporary entries created for stacks of original entries
  final Set<AvesEntry> _syntheticEntries = {};

  // entries and synthetic stacks sorted without sections
  List<AvesEntry> _filteredSortedEntries = [];

  // entries as displayed to the user (i.e. as ordered by sections, not an absolute order on all entries)
  List<AvesEntry>? _sectionedEntries;

  Map<SectionKey, List<AvesEntry>> sections = Map.unmodifiable({});

  CollectionLens({
    required this.source,
    Set<CollectionFilter?>? filters,
    this.id,
    this.listenToSource = true,
    this.stackBursts = true,
    this.stackDevelopedRaws = true,
    this.fixedSort = false,
    this.fixedSelection,
  }) : filters = (filters ?? {}).nonNulls.toSet(),
       burstPatterns = settings.collectionBurstPatterns,
       sectionFactor = settings.collectionSectionFactor,
       sortFactor = settings.collectionSortFactor,
       sortReverse = settings.collectionSortReverse {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
    id ??= hashCode;
    if (listenToSource) {
      final sourceEvents = source.eventBus;
      _subscriptions.add(sourceEvents.on<EntryAddedEvent>().listen((e) => _onEntryAdded(e.entries)));
      _subscriptions.add(sourceEvents.on<EntryRemovedEvent>().listen((e) => _onEntryRemoved(e.entries)));
      _subscriptions.add(
        sourceEvents.on<EntryMovedEvent>().listen((e) {
          switch (e.type) {
            case .copy:
            case .export:
              // refreshing new items is already handled via `EntryAddedEvent`s
              break;
            case .move:
            case .fromBin:
              refresh();
            case .toBin:
              _onEntryRemoved(e.entries);
          }
        }),
      );
      _subscriptions.add(sourceEvents.on<EntryRefreshedEvent>().listen((e) => refresh()));
      _subscriptions.add(sourceEvents.on<FilterVisibilityChangedEvent>().listen((e) => refresh()));
      _subscriptions.add(sourceEvents.on<CatalogMetadataChangedEvent>().listen((e) => refresh()));
      _subscriptions.add(
        sourceEvents.on<AddressMetadataChangedEvent>().listen((e) {
          if (this.filters.any((filter) => filter is LocationFilter)) {
            refresh();
          }
        }),
      );
      favourites.addListener(_onFavouritesChanged);
    }
    _subscriptions.add(
      settings.updateStream
          .where(
            (event) => [
              SettingKeys.collectionBurstPatternsKey,
              SettingKeys.collectionSortFactorKey,
              SettingKeys.collectionGroupFactorKey,
              SettingKeys.collectionSortReverseKey,
            ].contains(event.key),
          )
          .listen((_) => _onSettingsChanged()),
    );
    refresh();
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    favourites.removeListener(_onFavouritesChanged);
    filterChangeNotifier.dispose();
    layoutChangeNotifier.dispose();
    _disposeSyntheticEntries();
    super.dispose();
  }

  CollectionLens copyWith({
    CollectionSource? source,
    Set<CollectionFilter>? filters,
    bool? listenToSource,
    List<AvesEntry>? fixedSelection,
  }) => CollectionLens(
    source: source ?? this.source,
    filters: filters ?? this.filters,
    id: id,
    listenToSource: listenToSource ?? this.listenToSource,
    fixedSelection: fixedSelection ?? this.fixedSelection,
  );

  void _disposeSyntheticEntries() {
    _syntheticEntries.forEach((v) => v.dispose());
    _syntheticEntries.clear();
  }

  bool get isEmpty => _filteredSortedEntries.isEmpty;

  int get entryCount => _filteredSortedEntries.length;

  List<AvesEntry> get sortedEntries {
    _sectionedEntries ??= List.of(sections.entries.expand((kv) => kv.value));
    return _sectionedEntries!;
  }

  bool get showHeaders {
    bool showAlbumHeaders() => !filters.any((v) => v is StoredAlbumFilter && !v.reversed);

    switch (sortFactor) {
      case .date:
        switch (sectionFactor) {
          case .none:
            return false;
          case .album:
            return showAlbumHeaders();
          case .month:
            return true;
          case .day:
            return true;
        }
      case .name:
      case .path:
        return showAlbumHeaders();
      case .rating:
        return !filters.any((f) => f is RatingFilter);
      case .size:
      case .duration:
        return false;
    }
  }

  void addFilters(Set<CollectionFilter> newFilters) {
    if (filters.containsAll(newFilters)) return;
    for (final filter in newFilters) {
      filters.removeWhere((other) => !filter.isCompatible(other));
    }
    filters.addAll(newFilters);
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
    refresh();
    filterChangeNotifier.notify();
  }

  void _applyFilters() {
    final entries = fixedSelection ?? (filters.contains(TrashFilter.instance) ? source.trashedEntries : source.visibleEntries);
    _disposeSyntheticEntries();
    _filteredSortedEntries = List.of(filters.isEmpty ? entries : entries.where((entry) => filters.every((filter) => filter.test(entry))));

    if (stackBursts) {
      _stackBursts();
    }
    if (stackDevelopedRaws) {
      _stackDevelopedRaws();
    }
  }

  void _stackBursts() {
    final byBurstKey = groupBy<AvesEntry, String?>(_filteredSortedEntries, (entry) => entry.getBurstKey(burstPatterns)).whereNotNullKey();
    byBurstKey.forEach((burstKey, stackedEntries) {
      if (stackedEntries.length > 1) {
        stackedEntries.sort(AvesEntrySort.compareByName);
        final mainEntry = stackedEntries.first;
        final subEntries = stackedEntries.skip(1).toList();

        final stackEntry = mainEntry.copyWith(stackedEntries: stackedEntries);
        _syntheticEntries.add(stackEntry);

        subEntries.forEach(_filteredSortedEntries.remove);
        _filteredSortedEntries.replace(mainEntry, stackEntry);
      }
    });
  }

  void _stackDevelopedRaws() {
    final allRawEntries = _filteredSortedEntries.where((entry) => entry.isRaw).toSet();
    if (allRawEntries.isNotEmpty) {
      final allDevelopedEntries = _filteredSortedEntries.where((entry) => MimeTypes.developedRawImages.contains(entry.mimeType)).toSet();
      final rawEntriesByDir = groupBy<AvesEntry, String?>(allRawEntries, (entry) => entry.directory).whereNotNullKey();
      rawEntriesByDir.forEach((dir, dirRawEntries) {
        final dirDevelopedEntries = allDevelopedEntries.where((entry) => entry.directory == dir).toSet();
        for (final rawEntry in dirRawEntries) {
          final rawFilename = rawEntry.filenameWithoutExtension;
          final developedEntry = dirDevelopedEntries.firstWhereOrNull((entry) => entry.filenameWithoutExtension == rawFilename);
          if (developedEntry != null) {
            final mainEntry = developedEntry;
            final subEntry = rawEntry;

            final stackedEntries = [mainEntry, subEntry];
            final stackEntry = mainEntry.copyWith(stackedEntries: stackedEntries);
            _syntheticEntries.add(stackEntry);

            _filteredSortedEntries.remove(subEntry);
            _filteredSortedEntries.replace(mainEntry, stackEntry);
          }
        }
      });
    }
  }

  void _applySort() {
    if (fixedSort) return;

    switch (sortFactor) {
      case .date:
        _filteredSortedEntries.sort(AvesEntrySort.compareByDate);
      case .name:
        _filteredSortedEntries.sort(AvesEntrySort.compareByName);
      case .rating:
        _filteredSortedEntries.sort(AvesEntrySort.compareByRating);
      case .size:
        _filteredSortedEntries.sort(AvesEntrySort.compareBySize);
      case .duration:
        _filteredSortedEntries.sort(AvesEntrySort.compareByDuration);
      case .path:
        _filteredSortedEntries.sort(AvesEntrySort.compareByPath);
    }
    if (sortReverse) {
      _filteredSortedEntries = _filteredSortedEntries.reversed.toList();
    }
  }

  void _applySection() {
    if (fixedSort) {
      sections = Map.fromEntries([
        MapEntry(const SectionKey(), _filteredSortedEntries),
      ]);
    } else {
      switch (sortFactor) {
        case .date:
          switch (sectionFactor) {
            case .album:
              sections = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
            case .month:
              sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.monthTaken));
            case .day:
              sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.dayTaken));
            case .none:
              sections = Map.fromEntries([
                MapEntry(const SectionKey(), _filteredSortedEntries),
              ]);
          }
        case .name:
          final byAlbum = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
          final int Function(EntryAlbumSectionKey, EntryAlbumSectionKey) compare = sortReverse ? (a, b) => source.compareAlbumsByName(b.directory, a.directory) : (a, b) => source.compareAlbumsByName(a.directory, b.directory);
          sections = SplayTreeMap<EntryAlbumSectionKey, List<AvesEntry>>.of(byAlbum, compare);
        case .rating:
          sections = groupBy<AvesEntry, EntryRatingSectionKey>(_filteredSortedEntries, (entry) => EntryRatingSectionKey(entry.rating));
        case .size:
        case .duration:
          sections = Map.fromEntries([
            MapEntry(const SectionKey(), _filteredSortedEntries),
          ]);
        case .path:
          final byAlbum = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
          final int Function(EntryAlbumSectionKey, EntryAlbumSectionKey) compare = sortReverse ? (a, b) => source.compareAlbumsByPath(b.directory, a.directory) : (a, b) => source.compareAlbumsByPath(a.directory, b.directory);
          sections = SplayTreeMap<EntryAlbumSectionKey, List<AvesEntry>>.of(byAlbum, compare);
      }
    }
    sections = Map.unmodifiable(sections);
    _sectionedEntries = null;
    notifyListeners();
  }

  // metadata change should also trigger a full refresh
  // as dates impact sorting and sectioning
  void refresh() {
    _applyFilters();
    _applySort();
    _applySection();
  }

  void _onFavouritesChanged() {
    if (filters.any((filter) => filter is FavouriteFilter)) {
      refresh();
    }
  }

  void _onSettingsChanged() {
    final newBurstPatterns = settings.collectionBurstPatterns;
    final newSortFactor = settings.collectionSortFactor;
    final newSectionFactor = settings.collectionSectionFactor;
    final newSortReverse = settings.collectionSortReverse;

    final needFilter = burstPatterns != newBurstPatterns;
    final needSort = needFilter || sortFactor != newSortFactor || sortReverse != newSortReverse;
    final needSection = needSort || sectionFactor != newSectionFactor;

    if (needFilter) {
      burstPatterns = newBurstPatterns;
      _applyFilters();
    }
    if (needSort) {
      sortFactor = newSortFactor;
      sortReverse = newSortReverse;
      _applySort();
    }
    if (needSection) {
      sectionFactor = newSectionFactor;
      _applySection();
    }

    if (needFilter) {
      filterChangeNotifier.notify();
    }
    if (needSort || needSection) {
      layoutChangeNotifier.notify();
    }
  }

  void _onEntryAdded(Set<AvesEntry>? entries) {
    refresh();
  }

  void _onEntryRemoved(Set<AvesEntry> entries) {
    if (_syntheticEntries.isNotEmpty) {
      // find impacted stacks
      final obsoleteStacks = <AvesEntry>{};

      void _replaceStack(AvesEntry stackEntry, AvesEntry entry) {
        obsoleteStacks.add(stackEntry);
        fixedSelection?.replace(stackEntry, entry);
        _filteredSortedEntries.replace(stackEntry, entry);
        _sectionedEntries?.replace(stackEntry, entry);
        sections.forEach((key, sectionEntries) => sectionEntries.replace(stackEntry, entry));
      }

      final stacks = _filteredSortedEntries.where((entry) => entry.isStack).toSet();
      stacks.forEach((stackEntry) {
        final subEntries = stackEntry.stackedEntries!;
        if (subEntries.any(entries.contains)) {
          final mainEntry = subEntries.first;

          // remove the deleted sub-entries
          subEntries.removeWhere(entries.contains);

          switch (subEntries.length) {
            case 0:
              // remove the stack itself
              obsoleteStacks.add(stackEntry);
              break;
            case 1:
              // replace the stack by the last remaining sub-entry
              _replaceStack(stackEntry, subEntries.first);
              break;
            default:
              // keep the stack with the remaining sub-entries
              if (!subEntries.contains(mainEntry)) {
                // recreate the stack with the correct main entry
                _replaceStack(stackEntry, subEntries.first.copyWith(stackedEntries: subEntries));
              }
              break;
          }
        }
      });

      obsoleteStacks.forEach((stackEntry) {
        _syntheticEntries.remove(stackEntry);
        stackEntry.dispose();
      });
      entries.addAll(obsoleteStacks);
    }

    // we should remove obsolete entries and sections
    // but do not apply sort/section
    // as section order change would surprise the user while browsing
    fixedSelection?.removeWhere(entries.contains);
    _filteredSortedEntries.removeWhere(entries.contains);
    _sectionedEntries?.removeWhere(entries.contains);
    sections.forEach((key, sectionEntries) => sectionEntries.removeWhere(entries.contains));
    sections = Map.unmodifiable(Map.fromEntries(sections.entries.where((kv) => kv.value.isNotEmpty)));
    notifyListeners();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{id=$id, source=$source, filters=$filters, entryCount=$entryCount}';
}
