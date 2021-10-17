import 'dart:math';

import 'package:aves/geo/countries.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

mixin LocationMixin on SourceBase {
  static const _commitCountThreshold = 80;
  static const _stopCheckCountThreshold = 20;

  List<String> sortedCountries = List.unmodifiable([]);
  List<String> sortedPlaces = List.unmodifiable([]);

  Future<void> loadAddresses() async {
    final saved = await metadataDb.loadAddresses();
    final idMap = entryById;
    saved.forEach((metadata) => idMap[metadata.contentId]?.addressDetails = metadata);
    onAddressMetadataChanged();
  }

  Future<void> locateEntries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    await _locateCountries(controller, candidateEntries);
    await _locatePlaces(controller, candidateEntries);
  }

  static bool locateCountriesTest(AvesEntry entry) => entry.hasGps && !entry.hasAddress;

  static bool locatePlacesTest(AvesEntry entry) => entry.hasGps && !entry.hasFineAddress;

  // quick reverse geocoding to find the countries, using an offline asset
  Future<void> _locateCountries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return;

    final force = controller.force;
    final todo = (force ? candidateEntries.where((entry) => entry.hasGps) : candidateEntries.where(locateCountriesTest)).toSet();
    if (todo.isEmpty) return;

    stateNotifier.value = SourceState.locatingCountries;
    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    final countryCodeMap = await countryTopology.countryCodeMap(todo.map((entry) => entry.latLng!).toSet());
    final newAddresses = <AddressDetails>{};
    todo.forEach((entry) {
      final position = entry.latLng;
      final countryCode = countryCodeMap.entries.firstWhereOrNull((kv) => kv.value.contains(position))?.key;
      entry.setCountry(countryCode);
      if (entry.hasAddress) {
        newAddresses.add(entry.addressDetails!);
      }
      setProgress(done: ++progressDone, total: progressTotal);
    });
    if (newAddresses.isNotEmpty) {
      await metadataDb.saveAddresses(Set.unmodifiable(newAddresses));
      onAddressMetadataChanged();
    }
  }

  // full reverse geocoding, requiring Play Services and some connectivity
  Future<void> _locatePlaces(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return;
    if (!(await availability.canLocatePlaces)) return;

    final force = controller.force;
    final todo = (force ? candidateEntries.where((entry) => entry.hasGps) : candidateEntries.where(locatePlacesTest)).toSet();
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
    Tuple2<int, int> approximateLatLng(AvesEntry entry) {
      // entry has coordinates
      final catalogMetadata = entry.catalogMetadata!;
      final lat = catalogMetadata.latitude!;
      final lng = catalogMetadata.longitude!;
      return Tuple2<int, int>((lat * latLngFactor).round(), (lng * latLngFactor).round());
    }

    final located = visibleEntries.where((entry) => entry.hasGps).toSet().difference(todo);
    final knownLocations = <Tuple2<int, int>, AddressDetails?>{};
    located.forEach((entry) {
      knownLocations.putIfAbsent(approximateLatLng(entry), () => entry.addressDetails);
    });

    stateNotifier.value = SourceState.locatingPlaces;
    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    var stopCheckCount = 0;
    final newAddresses = <AddressDetails>{};
    for (final entry in todo) {
      final latLng = approximateLatLng(entry);
      if (knownLocations.containsKey(latLng)) {
        entry.addressDetails = knownLocations[latLng]?.copyWith(contentId: entry.contentId);
      } else {
        await entry.locatePlace(background: true, force: force, geocoderLocale: settings.appliedLocale);
        // it is intended to insert `null` if the geocoder failed,
        // so that we skip geocoding of following entries with the same coordinates
        knownLocations[latLng] = entry.addressDetails;
      }
      if (entry.hasFineAddress) {
        newAddresses.add(entry.addressDetails!);
        if (newAddresses.length >= _commitCountThreshold) {
          await metadataDb.saveAddresses(Set.unmodifiable(newAddresses));
          onAddressMetadataChanged();
          newAddresses.clear();
        }
        if (++stopCheckCount >= _stopCheckCountThreshold) {
          stopCheckCount = 0;
          if (controller.isStopping) return;
        }
      }
      setProgress(done: ++progressDone, total: progressTotal);
    }
    if (newAddresses.isNotEmpty) {
      await metadataDb.saveAddresses(Set.unmodifiable(newAddresses));
      onAddressMetadataChanged();
    }
  }

  void onAddressMetadataChanged() {
    updateLocations();
    eventBus.fire(AddressMetadataChangedEvent());
  }

  void updateLocations() {
    final locations = visibleEntries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails).whereNotNull().toList();
    final updatedPlaces = locations.map((address) => address.place).whereNotNull().where((v) => v.isNotEmpty).toSet().toList()..sort(compareAsciiUpperCase);
    if (!listEquals(updatedPlaces, sortedPlaces)) {
      sortedPlaces = List.unmodifiable(updatedPlaces);
      eventBus.fire(PlacesChangedEvent());
    }

    // the same country code could be found with different country names
    // e.g. if the locale changed between geocoding calls
    // so we merge countries by code, keeping only one name for each code
    final countriesByCode = Map.fromEntries(locations.map((address) {
      final code = address.countryCode;
      if (code == null || code.isEmpty) return null;
      return MapEntry(code, address.countryName);
    }).whereNotNull());
    final updatedCountries = countriesByCode.entries.map((kv) {
      final code = kv.key;
      final name = kv.value;
      return '${name != null && name.isNotEmpty ? name : code}${LocationFilter.locationSeparator}$code';
    }).toList()
      ..sort(compareAsciiUpperCase);
    if (!listEquals(updatedCountries, sortedCountries)) {
      sortedCountries = List.unmodifiable(updatedCountries);
      invalidateCountryFilterSummary();
      eventBus.fire(CountriesChangedEvent());
    }
  }

  // filter summary

  // by country code
  final Map<String, int> _filterEntryCountMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateCountryFilterSummary([Set<AvesEntry>? entries]) {
    if (_filterEntryCountMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    Set<String>? countryCodes;
    if (entries == null) {
      _filterEntryCountMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      countryCodes = entries.where((entry) => entry.hasAddress).map((entry) => entry.addressDetails?.countryCode).whereNotNull().toSet();
      countryCodes.forEach(_filterEntryCountMap.remove);
    }
    eventBus.fire(CountrySummaryInvalidatedEvent(countryCodes));
  }

  int countryEntryCount(LocationFilter filter) {
    final countryCode = filter.countryCode;
    if (countryCode == null) return 0;
    return _filterEntryCountMap.putIfAbsent(countryCode, () => visibleEntries.where(filter.test).length);
  }

  AvesEntry? countryRecentEntry(LocationFilter filter) {
    final countryCode = filter.countryCode;
    if (countryCode == null) return null;
    return _filterRecentEntryMap.putIfAbsent(countryCode, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }
}

class AddressMetadataChangedEvent {}

class PlacesChangedEvent {}

class CountriesChangedEvent {}

class CountrySummaryInvalidatedEvent {
  final Set<String>? countryCodes;

  const CountrySummaryInvalidatedEvent(this.countryCodes);
}
