import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class CollectionSource {
  final List<ImageEntry> _rawEntries;
  final EventBus _eventBus = EventBus();

  List<String> sortedAlbums = List.unmodifiable(const Iterable.empty());
  List<String> sortedTags = List.unmodifiable(const Iterable.empty());

  List<ImageEntry> get entries => List.unmodifiable(_rawEntries);

  EventBus get eventBus => _eventBus;

  int get albumCount => sortedAlbums.length;

  int get tagCount => sortedTags.length;

  CollectionSource({
    List<ImageEntry> entries,
  }) : _rawEntries = entries ?? [];

  Future<void> loadCatalogMetadata() async {
    final stopwatch = Stopwatch()..start();
    final saved = await metadataDb.loadMetadataEntries();
    _rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadCatalogMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms with ${saved.length} saved entries');
    onMetadataChanged();
  }

  Future<void> loadAddresses() async {
    final stopwatch = Stopwatch()..start();
    final saved = await metadataDb.loadAddresses();
    _rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.addressDetails = saved.firstWhere((address) => address.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms with ${saved.length} saved entries');
  }

  Future<void> catalogEntries() async {
    final stopwatch = Stopwatch()..start();
    final uncataloguedEntries = _rawEntries.where((entry) => !entry.isCatalogued).toList();
    if (uncataloguedEntries.isEmpty) return;

    final newMetadata = <CatalogMetadata>[];
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      if (entry.isCatalogued) {
        newMetadata.add(entry.catalogMetadata);
      }
    });
    if (newMetadata.isEmpty) return;

    await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
    onMetadataChanged();
    debugPrint('$runtimeType catalogEntries complete in ${stopwatch.elapsed.inSeconds}s with ${newMetadata.length} new entries');
  }

  void onMetadataChanged() {
    updateTags();
    eventBus.fire(MetadataChangedEvent());
  }

  Future<void> locateEntries() async {
    final stopwatch = Stopwatch()..start();
    final unlocatedEntries = _rawEntries.where((entry) => entry.hasGps && !entry.isLocated).toList();
    final newAddresses = <AddressDetails>[];
    await Future.forEach<ImageEntry>(unlocatedEntries, (entry) async {
      await entry.locate();
      if (entry.isLocated) {
        newAddresses.add(entry.addressDetails);
        if (newAddresses.length >= 50) {
          await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
          newAddresses.clear();
        }
      }
    });
    await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
    debugPrint('$runtimeType locateEntries complete in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  void updateAlbums() {
    final albums = _rawEntries.map((entry) => entry.directory).toSet();
    final sorted = albums.toList()
      ..sort((a, b) {
        final ua = getUniqueAlbumName(a, albums);
        final ub = getUniqueAlbumName(b, albums);
        return compareAsciiUpperCase(ua, ub);
      });
    sortedAlbums = List.unmodifiable(sorted);
  }

  void updateTags() {
    final tags = _rawEntries.expand((entry) => entry.xmpSubjects).toSet();
    final sorted = tags.toList()..sort(compareAsciiUpperCase);
    sortedTags = List.unmodifiable(sorted);
  }

  void add(ImageEntry entry) {
    _rawEntries.add(entry);
    eventBus.fire(EntryAddedEvent(entry));
  }

  void addAll(Iterable<ImageEntry> entries) {
    _rawEntries.addAll(entries);
    eventBus.fire(const EntryAddedEvent());
  }

  Future<bool> delete(ImageEntry entry) async {
    final success = await ImageFileService.delete(entry);
    if (success) {
      _rawEntries.remove(entry);
      eventBus.fire(EntryRemovedEvent(entry));
    }
    return success;
  }

  static String getUniqueAlbumName(String album, Iterable<String> albums) {
    final otherAlbums = albums.where((item) => item != album);
    final parts = album.split(separator);
    int partCount = 0;
    String testName;
    do {
      testName = separator + parts.skip(parts.length - ++partCount).join(separator);
    } while (otherAlbums.any((item) => item.endsWith(testName)));
    return parts.skip(parts.length - partCount).join(separator);
  }
}

class MetadataChangedEvent {}

class EntryAddedEvent {
  final ImageEntry entry;

  const EntryAddedEvent([this.entry]);
}

class EntryRemovedEvent {
  final ImageEntry entry;

  const EntryRemovedEvent(this.entry);
}
