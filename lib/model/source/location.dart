import 'dart:math';

import 'package:aves/model/availability.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/metadata.dart';
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
    visibleEntries.forEach((entry) {
      final contentId = entry.contentId;
      entry.addressDetails = saved.firstWhere((address) => address.contentId == contentId, orElse: () => null);
    });
    debugPrint('$runtimeType loadAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms for ${saved.length} entries');
    onAddressMetadataChanged();
  }

  Future<void> locateEntries() async {
    if (!(await availability.canGeolocate)) return;

//    final stopwatch = Stopwatch()..start();
    final byLocated = groupBy<AvesEntry, bool>(visibleEntries.where((entry) => entry.hasGps), (entry) => entry.isLocated);
    final todo = byLocated[false] ?? [];
    if (todo.isEmpty) return;

    // geocoder calls take between 150ms and 250ms
    // approximation and caching can reduce geocoder usage
    // for example, for a set of 2932 entries:
    // - 2476 calls (84%) when approximating to 6 decimal places (~10cm - individual humans)
    // - 2433 calls (83%) when approximating to 5 decimal places (~1m - individual trees, houses)
    // - 2277 calls (78%) when approximating to 4 decimal places (~10m - individual street, large buildings)
    // - 1521 calls (52%) when approximating to 3 decimal places (~100m - neighborhood, street)
    // -  652 calls (22%) when approximating to 2 decimal places (~1km - town or village)
    // cf https://en.wikipedia.org/wiki/Decimal_degrees#Precision
    final latLngFactor = pow(10, 2);
    Tuple2 approximateLatLng(AvesEntry entry) {
      final lat = entry.catalogMetadata?.latitude;
      final lng = entry.catalogMetadata?.longitude;
      if (lat == null || lng == null) return null;
      return Tuple2((lat * latLngFactor).round(), (lng * latLngFactor).round());
    }

    final knownLocations = <Tuple2, AddressDetails>{};
    byLocated[true]?.forEach((entry) => knownLocations.putIfAbsent(approximateLatLng(entry), () => entry.addressDetails));

    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    final newAddresses = <AddressDetails>[];
    await Future.forEach<AvesEntry>(todo, (entry) async {
      final latLng = approximateLatLng(entry);
      if (knownLocations.containsKey(latLng)) {
        entry.addressDetails = knownLocations[latLng]?.copyWith(contentId: entry.contentId);
      } else {
        await entry.locate(background: true);
        // it is intended to insert `null` if the geocoder failed,
        // so that we skip geocoding of following entries with the same coordinates
        knownLocations[latLng] = entry.addressDetails;
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
    final locations = visibleEntries.where((entry) => entry.isLocated).map((entry) => entry.addressDetails).toList();
    sortedPlaces = List<String>.unmodifiable(locations.map((address) => address.place).where((s) => s != null && s.isNotEmpty).toSet().toList()..sort(compareAsciiUpperCase));

    // the same country code could be found with different country names
    // e.g. if the locale changed between geolocating calls
    // so we merge countries by code, keeping only one name for each code
    final countriesByCode = Map.fromEntries(locations.map((address) => MapEntry(address.countryCode, address.countryName)).where((kv) => kv.key != null && kv.key.isNotEmpty));
    sortedCountries = List<String>.unmodifiable(countriesByCode.entries.map((kv) => '${kv.value}${LocationFilter.locationSeparator}${kv.key}').toList()..sort(compareAsciiUpperCase));

    invalidateCountryFilterSummary();
    eventBus.fire(LocationsChangedEvent());
  }

  // filter summary

  // by country code
  final Map<String, int> _filterEntryCountMap = {};
  final Map<String, AvesEntry> _filterRecentEntryMap = {};

  void invalidateCountryFilterSummary([Set<AvesEntry> entries]) {
    if (entries == null) {
      _filterEntryCountMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      final countryCodes = entries.where((entry) => entry.isLocated).map((entry) => entry.addressDetails.countryCode).toSet();
      countryCodes.forEach(_filterEntryCountMap.remove);
    }
  }

  int countryEntryCount(LocationFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.countryCode, () => visibleEntries.where(filter.test).length);
  }

  AvesEntry countryRecentEntry(LocationFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.countryCode, () => sortedEntriesByDate.firstWhere(filter.test, orElse: () => null));
  }
}

class AddressMetadataChangedEvent {}

class LocationsChangedEvent {}
