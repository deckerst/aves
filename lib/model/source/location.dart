import 'package:aves/model/filters/location.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

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
    final byLocated = groupBy<ImageEntry, bool>(rawEntries.where((entry) => entry.hasGps), (entry) => entry.isLocated);
    final todo = byLocated[false] ?? [];
    if (todo.isEmpty) return;

    // cache known locations to avoid querying the geocoder unless necessary
    // measuring the time it takes to process ~3000 coordinates (with ~10% of duplicates)
    // does not clearly show whether it is an actual optimization,
    // as results vary wildly (durations in "min:sec"):
    // - with no cache: 06:17, 08:36, 08:34
    // - with cache: 08:28, 05:42, 08:03, 05:58
    // anyway, in theory it should help!
    final knownLocations = <Tuple2<double, double>, AddressDetails>{};
    byLocated[true]?.forEach((entry) => knownLocations.putIfAbsent(entry.latLng, () => entry.addressDetails));

    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    final newAddresses = <AddressDetails>[];
    await Future.forEach<ImageEntry>(todo, (entry) async {
      if (knownLocations.containsKey(entry.latLng)) {
        entry.addressDetails = knownLocations[entry.latLng]?.copyWith(contentId: entry.contentId);
      } else {
        await entry.locate(background: true);
        // it is intended to insert `null` if the geocoder failed,
        // so that we skip geocoding of following entries with the same coordinates
        knownLocations[entry.latLng] = entry.addressDetails;
      }
      if (entry.isLocated) {
        newAddresses.add(entry.addressDetails);
        if (newAddresses.length >= _commitCountThreshold) {
          await metadataDb.saveAddresses(List.unmodifiable(newAddresses));
          onAddressMetadataChanged();
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
    List<String> lister(String Function(AddressDetails a) f) => List<String>.unmodifiable(locations.map(f).where((s) => s != null && s.isNotEmpty).toSet().toList()..sort(compareAsciiUpperCase));
    sortedCountries = lister((address) => '${address.countryName}${LocationFilter.locationSeparator}${address.countryCode}');
    sortedPlaces = lister((address) => address.place);

    invalidateFilterEntryCounts();
    eventBus.fire(LocationsChangedEvent());
  }

  Map<String, ImageEntry> getCountryEntries() {
    final locatedEntries = sortedEntriesForFilterList.where((entry) => entry.isLocated);
    return Map.fromEntries(sortedCountries.map((countryNameAndCode) {
      final split = countryNameAndCode.split(LocationFilter.locationSeparator);
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
