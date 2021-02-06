import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

mixin SourceBase {
  final List<AvesEntry> _rawEntries = [];

  List<AvesEntry> get rawEntries => List.unmodifiable(_rawEntries);

  final EventBus _eventBus = EventBus();

  EventBus get eventBus => _eventBus;

  List<AvesEntry> get sortedEntriesByDate;

  final StreamController<ProgressEvent> _progressStreamController = StreamController.broadcast();

  Stream<ProgressEvent> get progressStream => _progressStreamController.stream;

  void setProgress({@required int done, @required int total}) => _progressStreamController.add(ProgressEvent(done: done, total: total));
}

abstract class CollectionSource with SourceBase, AlbumMixin, LocationMixin, TagMixin {
  List<AvesEntry> _sortedEntriesByDate;

  @override
  List<AvesEntry> get sortedEntriesByDate {
    _sortedEntriesByDate ??= List.of(_rawEntries)..sort(AvesEntry.compareByDate);
    return _sortedEntriesByDate;
  }

  ValueNotifier<SourceState> stateNotifier = ValueNotifier(SourceState.ready);

  List<DateMetadata> _savedDates;

  Future<void> loadDates() async {
    final stopwatch = Stopwatch()..start();
    _savedDates = List.unmodifiable(await metadataDb.loadDates());
    debugPrint('$runtimeType loadDates complete in ${stopwatch.elapsed.inMilliseconds}ms for ${_savedDates.length} entries');
  }

  void addAll(Set<AvesEntry> entries) {
    if (entries.isEmpty) return;
    if (_rawEntries.isNotEmpty) {
      final newContentIds = entries.map((entry) => entry.contentId).toList();
      _rawEntries.removeWhere((entry) => newContentIds.contains(entry.contentId));
    }
    entries.forEach((entry) {
      final contentId = entry.contentId;
      entry.catalogDateMillis = _savedDates.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null)?.dateMillis;
    });
    _rawEntries.addAll(entries);
    addDirectory(_rawEntries.map((entry) => entry.directory));
    _invalidateFilterSummaries(entries);
    eventBus.fire(EntryAddedEvent(entries));
  }

  void removeEntries(Set<AvesEntry> entries) {
    if (entries.isEmpty) return;
    entries.forEach((entry) => entry.removeFromFavourites());
    _rawEntries.removeWhere(entries.contains);
    cleanEmptyAlbums(entries.map((entry) => entry.directory).toSet());
    updateLocations();
    updateTags();
    _invalidateFilterSummaries(entries);
    eventBus.fire(EntryRemovedEvent(entries));
  }

  void clearEntries() {
    _rawEntries.clear();
    cleanEmptyAlbums();
    updateLocations();
    updateTags();
    _invalidateFilterSummaries();
  }

  Future<void> _moveEntry(AvesEntry entry, Map newFields, bool isFavourite) async {
    final oldContentId = entry.contentId;
    final newContentId = newFields['contentId'] as int;
    final newDateModifiedSecs = newFields['dateModifiedSecs'] as int;
    // `dateModifiedSecs` changes when moving entries to another directory,
    // but it does not change when renaming the containing directory
    if (newDateModifiedSecs != null) entry.dateModifiedSecs = newDateModifiedSecs;
    entry.path = newFields['path'] as String;
    entry.uri = newFields['uri'] as String;
    entry.contentId = newContentId;
    entry.catalogMetadata = entry.catalogMetadata?.copyWith(contentId: newContentId);
    entry.addressDetails = entry.addressDetails?.copyWith(contentId: newContentId);

    await metadataDb.updateEntryId(oldContentId, entry);
    await metadataDb.updateMetadataId(oldContentId, entry.catalogMetadata);
    await metadataDb.updateAddressId(oldContentId, entry.addressDetails);
    if (isFavourite) {
      await favourites.move(oldContentId, entry);
    }
  }

  void updateAfterMove({
    @required Set<AvesEntry> todoEntries,
    @required Set<AvesEntry> favouriteEntries,
    @required bool copy,
    @required String destinationAlbum,
    @required Set<MoveOpEvent> movedOps,
  }) async {
    if (movedOps.isEmpty) return;

    final fromAlbums = <String>{};
    final movedEntries = <AvesEntry>{};
    if (copy) {
      movedOps.forEach((movedOp) {
        final sourceUri = movedOp.uri;
        final newFields = movedOp.newFields;
        final sourceEntry = todoEntries.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
        fromAlbums.add(sourceEntry.directory);
        movedEntries.add(sourceEntry?.copyWith(
          uri: newFields['uri'] as String,
          path: newFields['path'] as String,
          contentId: newFields['contentId'] as int,
          dateModifiedSecs: newFields['dateModifiedSecs'] as int,
        ));
      });
      await metadataDb.saveEntries(movedEntries);
      await metadataDb.saveMetadata(movedEntries.map((entry) => entry.catalogMetadata));
      await metadataDb.saveAddresses(movedEntries.map((entry) => entry.addressDetails));
    } else {
      await Future.forEach<MoveOpEvent>(movedOps, (movedOp) async {
        final newFields = movedOp.newFields;
        if (newFields.isNotEmpty) {
          final sourceUri = movedOp.uri;
          final entry = todoEntries.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
          if (entry != null) {
            fromAlbums.add(entry.directory);
            movedEntries.add(entry);
            // do not rely on current favourite repo state to assess whether the moved entry is a favourite
            // as source monitoring may already have removed the entry from the favourite repo
            final isFavourite = favouriteEntries.contains(entry);
            await _moveEntry(entry, newFields, isFavourite);
          }
        }
      });
    }

    if (copy) {
      addAll(movedEntries);
    } else {
      cleanEmptyAlbums(fromAlbums);
      addDirectory({destinationAlbum});
    }
    invalidateAlbumFilterSummary(directories: fromAlbums);
    _invalidateFilterSummaries(movedEntries);
    eventBus.fire(EntryMovedEvent(movedEntries));
  }

  bool get initialized => false;

  Future<void> init();

  Future<void> refresh();

  Future<void> refreshMetadata(Set<AvesEntry> entries);

  // filter summary

  void _invalidateFilterSummaries([Set<AvesEntry> entries]) {
    _sortedEntriesByDate = null;
    invalidateAlbumFilterSummary(entries: entries);
    invalidateCountryFilterSummary(entries);
    invalidateTagFilterSummary(entries);
  }

  int count(CollectionFilter filter) {
    if (filter is AlbumFilter) return albumEntryCount(filter);
    if (filter is LocationFilter) return countryEntryCount(filter);
    if (filter is TagFilter) return tagEntryCount(filter);
    return 0;
  }

  AvesEntry recentEntry(CollectionFilter filter) {
    if (filter is AlbumFilter) return albumRecentEntry(filter);
    if (filter is LocationFilter) return countryRecentEntry(filter);
    if (filter is TagFilter) return tagRecentEntry(filter);
    return null;
  }
}

enum SourceState { loading, cataloguing, locating, ready }

class EntryAddedEvent {
  final Set<AvesEntry> entries;

  const EntryAddedEvent([this.entries]);
}

class EntryRemovedEvent {
  final Set<AvesEntry> entries;

  const EntryRemovedEvent(this.entries);
}

class EntryMovedEvent {
  final Iterable<AvesEntry> entries;

  const EntryMovedEvent(this.entries);
}

class ProgressEvent {
  final int done, total;

  const ProgressEvent({@required this.done, @required this.total});
}
