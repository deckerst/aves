import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';

class ImageCollection with ChangeNotifier {
  final List<ImageEntry> _rawEntries;
  Map<dynamic, List<ImageEntry>> sections = Map();
  GroupFactor groupFactor = GroupFactor.date;
  SortFactor sortFactor = SortFactor.date;
  Set<String> albums = Set(), tags = Set();

  ImageCollection({
    @required List<ImageEntry> entries,
    @required this.groupFactor,
    @required this.sortFactor,
  }) : _rawEntries = entries {
    updateSections();
  }

  int get imageCount => _rawEntries.where((entry) => !entry.isVideo).length;

  int get videoCount => _rawEntries.where((entry) => entry.isVideo).length;

  int get albumCount => albums.length;

  int get tagCount => tags.length;

  List<ImageEntry> get sortedEntries => List.unmodifiable(sections.entries.expand((e) => e.value));

  sort(SortFactor sortFactor) {
    this.sortFactor = sortFactor;
    updateSections();
  }

  group(GroupFactor groupFactor) {
    this.groupFactor = groupFactor;
    updateSections();
  }

  updateSections() {
    _applySort();
    switch (sortFactor) {
      case SortFactor.date:
        switch (groupFactor) {
          case GroupFactor.album:
            sections = groupBy(_rawEntries, (entry) => entry.bucketDisplayName);
            break;
          case GroupFactor.date:
            sections = groupBy(_rawEntries, (entry) => entry.monthTaken);
            break;
        }
        break;
      case SortFactor.size:
        sections = Map.fromEntries([MapEntry('All', _rawEntries)]);
        break;
    }
    notifyListeners();
  }

  _applySort() {
    switch (sortFactor) {
      case SortFactor.date:
        _rawEntries.sort((a, b) => b.bestDate.compareTo(a.bestDate));
        break;
      case SortFactor.size:
        _rawEntries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
    }
  }

  add(ImageEntry entry) => _rawEntries.add(entry);

  Future<bool> delete(ImageEntry entry) async {
    final success = await ImageFileService.delete(entry);
    if (success) {
      _rawEntries.remove(entry);
      updateSections();
    }
    return success;
  }

  updateAlbums() => albums = _rawEntries.map((entry) => entry.bucketDisplayName).toSet();

  updateTags() => tags = _rawEntries.expand((entry) => entry.xmpSubjects).toSet();

  onMetadataChanged() {
    // metadata dates impact sorting and grouping
    updateSections();
    updateTags();
  }

  loadCatalogMetadata() async {
    debugPrint('$runtimeType loadCatalogMetadata start');
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

  loadAddresses() async {
    debugPrint('$runtimeType loadAddresses start');
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

  catalogEntries() async {
    debugPrint('$runtimeType catalogEntries start');
    final start = DateTime.now();
    final uncataloguedEntries = _rawEntries.where((entry) => !entry.isCatalogued);
    final newMetadata = List<CatalogMetadata>();
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      newMetadata.add(entry.catalogMetadata);
    });
    metadataDb.saveMetadata(List.unmodifiable(newMetadata));
    onMetadataChanged();
    debugPrint('$runtimeType catalogEntries complete in ${DateTime.now().difference(start).inSeconds}s with ${newMetadata.length} new entries');
  }

  locateEntries() async {
    debugPrint('$runtimeType locateEntries start');
    final start = DateTime.now();
    final unlocatedEntries = _rawEntries.where((entry) => entry.hasGps && !entry.isLocated);
    final newAddresses = List<AddressDetails>();
    await Future.forEach<ImageEntry>(unlocatedEntries, (entry) async {
      await entry.locate();
      newAddresses.add(entry.addressDetails);
      if (newAddresses.length >= 50) {
        metadataDb.saveAddresses(List.unmodifiable(newAddresses));
        newAddresses.clear();
      }
    });
    metadataDb.saveAddresses(List.unmodifiable(newAddresses));
    debugPrint('$runtimeType locateEntries complete in ${DateTime.now().difference(start).inSeconds}s');
  }

  ImageCollection filter(bool Function(ImageEntry) filter) {
    return ImageCollection(
      entries: _rawEntries.where(filter).toList(),
      groupFactor: groupFactor,
      sortFactor: sortFactor,
    );
  }
}

enum SortFactor { date, size }

enum GroupFactor { album, date }
