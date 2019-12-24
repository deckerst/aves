import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class ImageCollection with ChangeNotifier {
  final List<ImageEntry> _rawEntries;
  Map<dynamic, List<ImageEntry>> sections = {};
  GroupFactor groupFactor = GroupFactor.month;
  SortFactor sortFactor = SortFactor.date;
  List<String> sortedAlbums = List.unmodifiable(const Iterable.empty());
  List<String> sortedTags = List.unmodifiable(const Iterable.empty());

  ImageCollection({
    @required List<ImageEntry> entries,
    this.groupFactor,
    this.sortFactor,
  }) : _rawEntries = entries {
    updateSections();
  }

  int get imageCount => _rawEntries.where((entry) => !entry.isVideo).length;

  int get videoCount => _rawEntries.where((entry) => entry.isVideo).length;

  int get albumCount => sortedAlbums.length;

  int get tagCount => sortedTags.length;

  List<ImageEntry> get sortedEntries => List.unmodifiable(sections.entries.expand((e) => e.value));

  void sort(SortFactor sortFactor) {
    this.sortFactor = sortFactor;
    updateSections();
  }

  void group(GroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    updateSections();
  }

  void updateSections() {
    _applySort();
    switch (sortFactor) {
      case SortFactor.date:
        switch (groupFactor) {
          case GroupFactor.album:
            sections = groupBy(_rawEntries, (entry) => entry.directory);
            break;
          case GroupFactor.month:
            sections = groupBy(_rawEntries, (entry) => entry.monthTaken);
            break;
          case GroupFactor.day:
            sections = groupBy(_rawEntries, (entry) => entry.dayTaken);
            break;
        }
        break;
      case SortFactor.size:
        sections = Map.fromEntries([
          MapEntry('All', _rawEntries)
        ]);
        break;
    }
    notifyListeners();
  }

  void _applySort() {
    switch (sortFactor) {
      case SortFactor.date:
        _rawEntries.sort((a, b) => b.bestDate.compareTo(a.bestDate));
        break;
      case SortFactor.size:
        _rawEntries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
    }
  }

  void add(ImageEntry entry) => _rawEntries.add(entry);

  Future<bool> delete(ImageEntry entry) async {
    final success = await ImageFileService.delete(entry);
    if (success) {
      _rawEntries.remove(entry);
      updateSections();
    }
    return success;
  }

  void updateAlbums() {
    Set<String> albums = _rawEntries.map((entry) => entry.directory).toSet();
    List<String> sorted = albums.toList()
      ..sort((a, b) {
        final ua = getUniqueAlbumName(a, albums);
        final ub = getUniqueAlbumName(b, albums);
        return compareAsciiUpperCase(ua, ub);
      });
    sortedAlbums = List.unmodifiable(sorted);
  }

  void updateTags() {
    Set<String> tags = _rawEntries.expand((entry) => entry.xmpSubjects).toSet();
    List<String> sorted = tags.toList()..sort(compareAsciiUpperCase);
    sortedTags = List.unmodifiable(sorted);
  }

  void onMetadataChanged() {
    // metadata dates impact sorting and grouping
    updateSections();
    updateTags();
  }

  Future<void> loadCatalogMetadata() async {
    final start = DateTime.now();
    final saved = await metadataDb.loadMetadataEntries();
    _rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
      }
    });
    onMetadataChanged();
    debugPrint('$runtimeType loadCatalogMetadata complete in ${DateTime.now().difference(start).inSeconds}s with ${saved.length} saved entries');
  }

  Future<void> loadAddresses() async {
    final start = DateTime.now();
    final saved = await metadataDb.loadAddresses();
    _rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.addressDetails = saved.firstWhere((address) => address.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadAddresses complete in ${DateTime.now().difference(start).inSeconds}s with ${saved.length} saved entries');
  }

  Future<void> catalogEntries() async {
    final start = DateTime.now();
    final uncataloguedEntries = _rawEntries.where((entry) => !entry.isCatalogued).toList();
    final newMetadata = <CatalogMetadata>[];
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      newMetadata.add(entry.catalogMetadata);
    });
    await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
    onMetadataChanged();
    debugPrint('$runtimeType catalogEntries complete in ${DateTime.now().difference(start).inSeconds}s with ${newMetadata.length} new entries');
  }

  Future<void> locateEntries() async {
    final start = DateTime.now();
    final unlocatedEntries = _rawEntries.where((entry) => entry.hasGps && !entry.isLocated).toList();
    final newAddresses = <AddressDetails>[];
    await Future.forEach<ImageEntry>(unlocatedEntries, (entry) async {
      await entry.locate();
      newAddresses.add(entry.addressDetails);
      if (newAddresses.length >= 50) {
        await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
        newAddresses.clear();
      }
    });
    await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
    debugPrint('$runtimeType locateEntries complete in ${DateTime.now().difference(start).inSeconds}s');
  }

  ImageCollection filter(bool Function(ImageEntry) filter) {
    return ImageCollection(
      entries: _rawEntries.where(filter).toList(),
      groupFactor: groupFactor,
      sortFactor: sortFactor,
    );
  }

  String getUniqueAlbumName(String album, Iterable<String> albums) {
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

enum SortFactor { date, size }

enum GroupFactor { album, month, day }
