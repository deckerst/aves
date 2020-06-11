import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

mixin SourceBase {
  final List<ImageEntry> _rawEntries = [];

  List<ImageEntry> get rawEntries => List.unmodifiable(_rawEntries);

  final EventBus _eventBus = EventBus();

  EventBus get eventBus => _eventBus;

  List<ImageEntry> get sortedEntriesForFilterList;

  final Map<CollectionFilter, int> _filterEntryCountMap = {};

  void invalidateFilterEntryCounts() => _filterEntryCountMap.clear();
}

class CollectionSource with SourceBase, AlbumMixin, LocationMixin, TagMixin {
  @override
  List<ImageEntry> get sortedEntriesForFilterList => CollectionLens(
        source: this,
        groupFactor: GroupFactor.month,
        sortFactor: SortFactor.date,
      ).sortedEntries;

  ValueNotifier<SourceState> stateNotifier = ValueNotifier<SourceState>(SourceState.ready);

  List<DateMetadata> _savedDates;

  Future<void> loadDates() async {
    final stopwatch = Stopwatch()..start();
    _savedDates = List.unmodifiable(await metadataDb.loadDates());
    debugPrint('$runtimeType loadDates complete in ${stopwatch.elapsed.inMilliseconds}ms for ${_savedDates.length} saved entries');
  }

  void addAll(Iterable<ImageEntry> entries) {
    entries.forEach((entry) {
      final contentId = entry.contentId;
      entry.catalogDateMillis = _savedDates.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null)?.dateMillis;
    });
    _rawEntries.addAll(entries);
    addFolderPath(_rawEntries.map((entry) => entry.directory));
    invalidateFilterEntryCounts();
    eventBus.fire(const EntryAddedEvent());
  }

  void removeEntries(Iterable<ImageEntry> entries) {
    entries.forEach((entry) => entry.removeFromFavourites());
    _rawEntries.removeWhere(entries.contains);
    // TODO TLAD invalidate locations/tags, like cleaning albums
    cleanEmptyAlbums(entries.map((entry) => entry.directory).toSet());
    invalidateFilterEntryCounts();
    eventBus.fire(EntryRemovedEvent(entries));
  }

  void clearEntries() {
    _rawEntries.clear();
    cleanEmptyAlbums();
    updateAlbums();
    updateLocations();
    updateTags();
    invalidateFilterEntryCounts();
  }

  void applyMove({
    @required Iterable<ImageEntry> entries,
    @required Set<String> fromAlbums,
    @required String toAlbum,
    @required bool copy,
  }) {
    if (copy) {
      addAll(entries);
    } else {
      cleanEmptyAlbums(fromAlbums);
      addFolderPath({toAlbum});
    }
    updateAlbums();
    invalidateFilterEntryCounts();
    eventBus.fire(EntryMovedEvent(entries));
  }

  int count(CollectionFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter, () => _rawEntries.where((entry) => filter.filter(entry)).length);
  }
}

enum SourceState { loading, cataloguing, locating, ready }

class EntryAddedEvent {
  final ImageEntry entry;

  const EntryAddedEvent([this.entry]);
}

class EntryRemovedEvent {
  final Iterable<ImageEntry> entries;

  const EntryRemovedEvent(this.entries);
}

class EntryMovedEvent {
  final Iterable<ImageEntry> entries;

  const EntryMovedEvent(this.entries);
}
