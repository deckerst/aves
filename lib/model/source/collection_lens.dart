import 'dart:async';
import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
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
import 'package:aves/utils/collection_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CollectionLens with ChangeNotifier {
  final CollectionSource source;
  final Set<CollectionFilter> filters;
  List<String> burstPatterns;
  EntryGroupFactor sectionFactor;
  EntrySortFactor sortFactor;
  bool sortReverse;
  final AChangeNotifier filterChangeNotifier = AChangeNotifier(), sortSectionChangeNotifier = AChangeNotifier();
  final List<StreamSubscription> _subscriptions = [];
  int? id;
  bool listenToSource, stackBursts, stackDevelopedRaws, fixedSort;
  List<AvesEntry>? fixedSelection;

  final Set<AvesEntry> _syntheticEntries = {};
  List<AvesEntry> _filteredSortedEntries = [];

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
  })  : filters = (filters ?? {}).nonNulls.toSet(),
        burstPatterns = settings.collectionBurstPatterns,
        sectionFactor = settings.collectionSectionFactor,
        sortFactor = settings.collectionSortFactor,
        sortReverse = settings.collectionSortReverse {
    id ??= hashCode;
    if (listenToSource) {
      final sourceEvents = source.eventBus;
      _subscriptions.add(sourceEvents.on<EntryAddedEvent>().listen((e) => _onEntryAdded(e.entries)));
      _subscriptions.add(sourceEvents.on<EntryRemovedEvent>().listen((e) => _onEntryRemoved(e.entries)));
      _subscriptions.add(sourceEvents.on<EntryMovedEvent>().listen((e) {
        switch (e.type) {
          case MoveType.copy:
          case MoveType.export:
            // refreshing new items is already handled via `EntryAddedEvent`s
            break;
          case MoveType.move:
          case MoveType.fromBin:
            refresh();
          case MoveType.toBin:
            _onEntryRemoved(e.entries);
        }
      }));
      _subscriptions.add(sourceEvents.on<EntryRefreshedEvent>().listen((e) => refresh()));
      _subscriptions.add(sourceEvents.on<FilterVisibilityChangedEvent>().listen((e) => refresh()));
      _subscriptions.add(sourceEvents.on<CatalogMetadataChangedEvent>().listen((e) => refresh()));
      _subscriptions.add(sourceEvents.on<AddressMetadataChangedEvent>().listen((e) {
        if (this.filters.any((filter) => filter is LocationFilter)) {
          refresh();
        }
      }));
      favourites.addListener(_onFavouritesChanged);
    }
    _subscriptions.add(settings.updateStream
        .where((event) => [
              SettingKeys.collectionBurstPatternsKey,
              SettingKeys.collectionSortFactorKey,
              SettingKeys.collectionGroupFactorKey,
              SettingKeys.collectionSortReverseKey,
            ].contains(event.key))
        .listen((_) => _onSettingsChanged()));
    refresh();
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    favourites.removeListener(_onFavouritesChanged);
    filterChangeNotifier.dispose();
    sortSectionChangeNotifier.dispose();
    _disposeSyntheticEntries();
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

  void _disposeSyntheticEntries() {
    _syntheticEntries.forEach((v) => v.dispose());
    _syntheticEntries.clear();
  }

  bool get isEmpty => _filteredSortedEntries.isEmpty;

  int get entryCount => _filteredSortedEntries.length;

  // sorted as displayed to the user, i.e. sorted then sectioned, not an absolute order on all entries
  List<AvesEntry>? _sortedEntries;

  List<AvesEntry> get sortedEntries {
    _sortedEntries ??= List.of(sections.entries.expand((kv) => kv.value));
    return _sortedEntries!;
  }

  bool get showHeaders {
    bool showAlbumHeaders() => !filters.any((v) => v is AlbumFilter && !v.reversed);

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
      case EntrySortFactor.duration:
        return false;
    }
  }

  void addFilter(CollectionFilter filter) {
    if (filters.contains(filter)) return;
    filters.removeWhere((other) => !filter.isCompatible(other));
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
    refresh();
    filterChangeNotifier.notifyListeners();
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
    byBurstKey.forEach((burstKey, entries) {
      if (entries.length > 1) {
        entries.sort(AvesEntrySort.compareByName);
        final mainEntry = entries.first;
        final stackEntry = mainEntry.copyWith(stackedEntries: entries);
        _syntheticEntries.add(stackEntry);

        entries.skip(1).forEach((subEntry) {
          _filteredSortedEntries.remove(subEntry);
        });
        final index = _filteredSortedEntries.indexOf(mainEntry);
        _filteredSortedEntries.removeAt(index);
        _filteredSortedEntries.insert(index, stackEntry);
      }
    });
  }

  void _stackDevelopedRaws() {
    final allRawEntries = _filteredSortedEntries.where((entry) => entry.isRaw).toSet();
    if (allRawEntries.isNotEmpty) {
      final allDevelopedEntries = _filteredSortedEntries.where(MimeFilter(MimeTypes.jpeg).test).toSet();
      final rawEntriesByDir = groupBy<AvesEntry, String?>(allRawEntries, (entry) => entry.directory);
      rawEntriesByDir.forEach((dir, dirRawEntries) {
        if (dir != null) {
          final dirDevelopedEntries = allDevelopedEntries.where((entry) => entry.directory == dir).toSet();
          for (final rawEntry in dirRawEntries) {
            final rawFilename = rawEntry.filenameWithoutExtension;
            final developedEntry = dirDevelopedEntries.firstWhereOrNull((entry) => entry.filenameWithoutExtension == rawFilename);
            if (developedEntry != null) {
              final stackEntry = rawEntry.copyWith(stackedEntries: [rawEntry, developedEntry]);
              _syntheticEntries.add(stackEntry);

              _filteredSortedEntries.remove(developedEntry);
              final index = _filteredSortedEntries.indexOf(rawEntry);
              _filteredSortedEntries.removeAt(index);
              _filteredSortedEntries.insert(0, stackEntry);
            }
          }
        }
      });
    }
  }

  void _applySort() {
    if (fixedSort) return;

    switch (sortFactor) {
      case EntrySortFactor.date:
        _filteredSortedEntries.sort(AvesEntrySort.compareByDate);
      case EntrySortFactor.name:
        _filteredSortedEntries.sort(AvesEntrySort.compareByName);
      case EntrySortFactor.rating:
        _filteredSortedEntries.sort(AvesEntrySort.compareByRating);
      case EntrySortFactor.size:
        _filteredSortedEntries.sort(AvesEntrySort.compareBySize);
      case EntrySortFactor.duration:
        _filteredSortedEntries.sort(AvesEntrySort.compareByDuration);
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
        case EntrySortFactor.date:
          switch (sectionFactor) {
            case EntryGroupFactor.album:
              sections = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
            case EntryGroupFactor.month:
              sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.monthTaken));
            case EntryGroupFactor.day:
              sections = groupBy<AvesEntry, EntryDateSectionKey>(_filteredSortedEntries, (entry) => EntryDateSectionKey(entry.dayTaken));
            case EntryGroupFactor.none:
              sections = Map.fromEntries([
                MapEntry(const SectionKey(), _filteredSortedEntries),
              ]);
          }
        case EntrySortFactor.name:
          final byAlbum = groupBy<AvesEntry, EntryAlbumSectionKey>(_filteredSortedEntries, (entry) => EntryAlbumSectionKey(entry.directory));
          final int Function(EntryAlbumSectionKey, EntryAlbumSectionKey) compare = sortReverse ? (a, b) => source.compareAlbumsByName(b.directory, a.directory) : (a, b) => source.compareAlbumsByName(a.directory, b.directory);
          sections = SplayTreeMap<EntryAlbumSectionKey, List<AvesEntry>>.of(byAlbum, compare);
        case EntrySortFactor.rating:
          sections = groupBy<AvesEntry, EntryRatingSectionKey>(_filteredSortedEntries, (entry) => EntryRatingSectionKey(entry.rating));
        case EntrySortFactor.size:
        case EntrySortFactor.duration:
          sections = Map.fromEntries([
            MapEntry(const SectionKey(), _filteredSortedEntries),
          ]);
      }
    }
    sections = Map.unmodifiable(sections);
    _sortedEntries = null;
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
      filterChangeNotifier.notifyListeners();
    }
    if (needSort || needSection) {
      sortSectionChangeNotifier.notifyListeners();
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
        _sortedEntries?.replace(stackEntry, entry);
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
    _sortedEntries?.removeWhere(entries.contains);
    sections.forEach((key, sectionEntries) => sectionEntries.removeWhere(entries.contains));
    sections = Map.unmodifiable(Map.fromEntries(sections.entries.where((kv) => kv.value.isNotEmpty)));
    notifyListeners();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{id=$id, source=$source, filters=$filters, entryCount=$entryCount}';
}
