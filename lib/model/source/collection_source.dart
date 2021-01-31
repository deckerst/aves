import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

mixin SourceBase {
  final List<AvesEntry> _rawEntries = [];

  List<AvesEntry> get rawEntries => List.unmodifiable(_rawEntries);

  final EventBus _eventBus = EventBus();

  EventBus get eventBus => _eventBus;

  List<AvesEntry> get sortedEntriesForFilterList;

  final Map<CollectionFilter, int> _filterEntryCountMap = {};

  void invalidateFilterEntryCounts() => _filterEntryCountMap.clear();

  final StreamController<ProgressEvent> _progressStreamController = StreamController.broadcast();

  Stream<ProgressEvent> get progressStream => _progressStreamController.stream;

  void setProgress({@required int done, @required int total}) => _progressStreamController.add(ProgressEvent(done: done, total: total));
}

abstract class CollectionSource with SourceBase, AlbumMixin, LocationMixin, TagMixin {
  @override
  List<AvesEntry> get sortedEntriesForFilterList => CollectionLens(
        source: this,
        groupFactor: EntryGroupFactor.none,
        sortFactor: EntrySortFactor.date,
      ).sortedEntries;

  ValueNotifier<SourceState> stateNotifier = ValueNotifier(SourceState.ready);

  List<DateMetadata> _savedDates;

  Future<void> loadDates() async {
    final stopwatch = Stopwatch()..start();
    _savedDates = List.unmodifiable(await metadataDb.loadDates());
    debugPrint('$runtimeType loadDates complete in ${stopwatch.elapsed.inMilliseconds}ms for ${_savedDates.length} entries');
  }

  void addAll(Iterable<AvesEntry> entries) {
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
    addFolderPath(_rawEntries.map((entry) => entry.directory));
    invalidateFilterEntryCounts();
    eventBus.fire(EntryAddedEvent());
  }

  void removeEntries(List<AvesEntry> entries) {
    entries.forEach((entry) => entry.removeFromFavourites());
    _rawEntries.removeWhere(entries.contains);
    cleanEmptyAlbums(entries.map((entry) => entry.directory).toSet());
    updateLocations();
    updateTags();
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

  // `dateModifiedSecs` changes when moving entries to another directory,
  // but it does not change when renaming the containing directory
  Future<void> moveEntry(AvesEntry entry, Map newFields) async {
    final oldContentId = entry.contentId;
    final newContentId = newFields['contentId'] as int;
    final newDateModifiedSecs = newFields['dateModifiedSecs'] as int;
    if (newDateModifiedSecs != null) entry.dateModifiedSecs = newDateModifiedSecs;
    entry.path = newFields['path'] as String;
    entry.uri = newFields['uri'] as String;
    entry.contentId = newContentId;
    entry.catalogMetadata = entry.catalogMetadata?.copyWith(contentId: newContentId);
    entry.addressDetails = entry.addressDetails?.copyWith(contentId: newContentId);

    await metadataDb.updateEntryId(oldContentId, entry);
    await metadataDb.updateMetadataId(oldContentId, entry.catalogMetadata);
    await metadataDb.updateAddressId(oldContentId, entry.addressDetails);
    await favourites.move(oldContentId, entry);
  }

  void updateAfterMove({
    @required Set<AvesEntry> selection,
    @required bool copy,
    @required String destinationAlbum,
    @required Iterable<MoveOpEvent> movedOps,
  }) async {
    if (movedOps.isEmpty) return;

    final fromAlbums = <String>{};
    final movedEntries = <AvesEntry>[];
    if (copy) {
      movedOps.forEach((movedOp) {
        final sourceUri = movedOp.uri;
        final newFields = movedOp.newFields;
        final sourceEntry = selection.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
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
          final entry = selection.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
          if (entry != null) {
            fromAlbums.add(entry.directory);
            movedEntries.add(entry);
            await moveEntry(entry, newFields);
          }
        }
      });
    }

    if (copy) {
      addAll(movedEntries);
    } else {
      cleanEmptyAlbums(fromAlbums);
      addFolderPath({destinationAlbum});
    }
    updateAlbums();
    invalidateFilterEntryCounts();
    eventBus.fire(EntryMovedEvent(movedEntries));
  }

  int count(CollectionFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter, () => _rawEntries.where((entry) => filter.filter(entry)).length);
  }

  bool get initialized => false;

  Future<void> init();

  Future<void> refresh();

  Future<void> refreshMetadata(Set<AvesEntry> entries);
}

enum SourceState { loading, cataloguing, locating, ready }

class EntryAddedEvent {
  final AvesEntry entry;

  const EntryAddedEvent([this.entry]);
}

class EntryRemovedEvent {
  final Iterable<AvesEntry> entries;

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
