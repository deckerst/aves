import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:flutter/material.dart';

class ImageCollection with ChangeNotifier {
  final List<ImageEntry> entries;

  ImageCollection(this.entries);

  Future<bool> delete(ImageEntry entry) async {
    final success = await ImageFileService.delete(entry);
    if (success) {
      entries.remove(entry);
      notifyListeners();
    }
    return success;
  }

  loadCatalogMetadata() async {
    debugPrint('$runtimeType loadCatalogMetadata start');
    final start = DateTime.now();
    final saved = await metadataDb.loadMetadataEntries();
    entries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadCatalogMetadata complete in ${DateTime.now().difference(start).inSeconds}s with ${saved.length} saved entries');
  }

  loadAddresses() async {
    debugPrint('$runtimeType loadAddresses start');
    final start = DateTime.now();
    final saved = await metadataDb.loadAddresses();
    entries.forEach((entry) {
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
    final uncataloguedEntries = entries.where((entry) => !entry.isCatalogued);
    final newMetadata = List<CatalogMetadata>();
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      newMetadata.add(entry.catalogMetadata);
    });
    debugPrint('$runtimeType catalogEntries complete in ${DateTime.now().difference(start).inSeconds}s with ${newMetadata.length} new entries');

    // sort with more accurate date
    entries.sort((a, b) => b.bestDate.compareTo(a.bestDate));

    metadataDb.saveMetadata(List.unmodifiable(newMetadata));
  }

  locateEntries() async {
    debugPrint('$runtimeType locateEntries start');
    final start = DateTime.now();
    final unlocatedEntries = entries.where((entry) => !entry.isLocated);
    final newAddresses = List<AddressDetails>();
    await Future.forEach<ImageEntry>(unlocatedEntries, (entry) async {
      await entry.locate();
      newAddresses.add(entry.addressDetails);
      if (newAddresses.length >= 50) {
        metadataDb.saveAddresses(List.unmodifiable(newAddresses));
        newAddresses.clear();
      }
    });
    debugPrint('$runtimeType locateEntries complete in ${DateTime.now().difference(start).inSeconds}s');
  }
}
