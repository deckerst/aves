import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin LocationMixin on SourceBase {
  static const _commitCountThreshold = 50;

  List<String> sortedCountries = List.unmodifiable([]);
  List<String> sortedPlaces = List.unmodifiable([]);

  Future<void> loadAddresses() async {
    final stopwatch = Stopwatch()..start();
    final saved = await metadataDb.loadAddresses();
    rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      entry.addressDetails = saved.firstWhere((address) => address.contentId == contentId, orElse: () => null);
    });
    debugPrint('$runtimeType loadAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms for ${saved.length} entries');
    onAddressMetadataChanged();
  }

  Future<void> locateEntries() async {
//    final stopwatch = Stopwatch()..start();
    final todo = rawEntries.where((entry) => entry.hasGps && !entry.isLocated).toList();
    if (todo.isEmpty) return;

    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    final newAddresses = <AddressDetails>[];
    await Future.forEach<ImageEntry>(todo, (entry) async {
      await entry.locate(background: true);
      if (entry.isLocated) {
        newAddresses.add(entry.addressDetails);
        if (newAddresses.length >= _commitCountThreshold) {
          await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
          newAddresses.clear();
        }
      }
      setProgress(done: ++progressDone, total: progressTotal);
    });
    await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
    onAddressMetadataChanged();
//    debugPrint('$runtimeType locateEntries complete in ${stopwatch.elapsed.inSeconds}s');
  }

  void onAddressMetadataChanged() {
    updateLocations();
    eventBus.fire(AddressMetadataChangedEvent());
  }

  void updateLocations() {
    final locations = rawEntries.where((entry) => entry.isLocated).map((entry) => entry.addressDetails).toList();
    final lister = (String Function(AddressDetails a) f) => List<String>.unmodifiable(locations.map(f).where((s) => s != null && s.isNotEmpty).toSet().toList()..sort(compareAsciiUpperCase));
    sortedCountries = lister((address) => '${address.countryName};${address.countryCode}');
    sortedPlaces = lister((address) => address.place);

    invalidateFilterEntryCounts();
    eventBus.fire(LocationsChangedEvent());
  }

  Map<String, ImageEntry> getCountryEntries() {
    final locatedEntries = sortedEntriesForFilterList.where((entry) => entry.isLocated);
    return Map.fromEntries(sortedCountries.map((countryNameAndCode) {
      final split = countryNameAndCode.split(';');
      ImageEntry entry;
      if (split.length > 1) {
        final countryCode = split[1];
        entry = locatedEntries.firstWhere((entry) => entry.addressDetails.countryCode == countryCode, orElse: () => null);
      }
      return MapEntry(countryNameAndCode, entry);
    }));
  }
}

class AddressMetadataChangedEvent {}

class LocationsChangedEvent {}
