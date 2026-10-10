import 'dart:math';

import 'package:aves/geo/countries.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/model/source/location/place.dart';
import 'package:aves/model/source/location/state.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';

mixin LocationMixin on CountryMixin, StateMixin, PlaceMixin {
  static const commitCountThreshold = 200;
  static const _stopCheckCountThreshold = 50;

  List<String>? _sortedCountries;
  List<String>? _sortedStates;
  List<String>? _sortedPlaces;

  List<String> get sortedCountries {
    if (_sortedCountries == null) _computeLocations();
    return _sortedCountries!;
  }

  List<String> get sortedStates {
    if (_sortedStates == null) _computeLocations();
    return _sortedStates!;
  }

  List<String> get sortedPlaces {
    if (_sortedPlaces == null) _computeLocations();
    return _sortedPlaces!;
  }

  Future<void> loadAddresses({Set<int>? ids}) async {
    final saved = await (ids != null ? localMediaDb.loadAddressesById(ids) : localMediaDb.loadAddresses());
    saved.forEach((metadata) => getEntryById(metadata.id)?.addressDetails = metadata);
    invalidateEntries();
    onAddressMetadataChanged();
  }

  // returns whether some entries got processed
  Future<bool> locateEntries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    var processed = await _locateCountries(controller, candidateEntries);
    processed |= await _locatePlaces(controller, candidateEntries);

    final unlocatedIds = candidateEntries.where((entry) => !entry.hasGps).map((entry) => entry.id).toSet();
    if (unlocatedIds.isNotEmpty) {
      await localMediaDb.removeIds(unlocatedIds, dataTypes: {EntryDataType.address});
      onAddressMetadataChanged();
    }
    return processed;
  }

  static bool locateCountriesTest(AvesEntry entry) => entry.hasGps && !entry.hasAddress;

  static bool locatePlacesTest(AvesEntry entry) => entry.hasGps && !entry.hasFineAddress;

  // quick reverse geocoding to find the countries, using an offline asset
  // returns whether some entries got processed
  Future<bool> _locateCountries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return false;

    final force = controller.force;
    final todo = (force ? candidateEntries.where((entry) => entry.hasGps) : candidateEntries.where(locateCountriesTest)).toSet();
    if (todo.isEmpty) return false;

    state = SourceState.locatingCountries;
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
      await localMediaDb.saveAddresses(Set.unmodifiable(newAddresses));
      onAddressMetadataChanged();
    }
    return true;
  }

  // full reverse geocoding, requiring geocoder and some connectivity
  // returns whether some entries got processed
  Future<bool> _locatePlaces(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return false;
    if (!await availability.canLocatePlaces) return false;

    final force = controller.force;
    final todo = (force ? candidateEntries.where((entry) => entry.hasGps) : candidateEntries.where(locatePlacesTest)).toSet();
    if (todo.isEmpty) return false;

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
    (int latitude, int longitude) approximateLatLng(AvesEntry entry) {
      // entry has coordinates
      final catalogMetadata = entry.catalogMetadata!;
      final lat = catalogMetadata.latitude!;
      final lng = catalogMetadata.longitude!;
      return ((lat * latLngFactor).round(), (lng * latLngFactor).round());
    }

    final located = visibleEntries.where((entry) => entry.hasGps).toSet().difference(todo);
    final knownLocations = <(int, int), AddressDetails?>{};
    located.forEach((entry) {
      final address = entry.addressDetails;
      if (address != null && address.isValid) {
        knownLocations.putIfAbsent(approximateLatLng(entry), () => address);
      }
    });

    state = SourceState.locatingPlaces;
    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    var stopCheckCount = 0;
    final newAddresses = <AddressDetails>{};
    for (final entry in todo) {
      final latLng = approximateLatLng(entry);
      if (knownLocations.containsKey(latLng)) {
        entry.addressDetails = knownLocations[latLng]?.copyWith(id: entry.id);
      } else {
        await entry.locatePlace(background: true, force: force, geocoderLocale: settings.avesLocale);
        // it is intended to insert `null` if the geocoder failed,
        // so that we skip geocoding of following entries with the same coordinates
        knownLocations[latLng] = entry.addressDetails;
      }
      if (entry.hasFineAddress) {
        newAddresses.add(entry.addressDetails!);
        if (newAddresses.length >= commitCountThreshold) {
          await localMediaDb.saveAddresses(Set.unmodifiable(newAddresses));
          onAddressMetadataChanged();
          newAddresses.clear();
        }
        if (++stopCheckCount >= _stopCheckCountThreshold) {
          stopCheckCount = 0;
          if (controller.isStopping) return true;
        }
      }
      setProgress(done: ++progressDone, total: progressTotal);
    }
    if (newAddresses.isNotEmpty) {
      await localMediaDb.saveAddresses(Set.unmodifiable(newAddresses));
      onAddressMetadataChanged();
    }
    return true;
  }

  void onAddressMetadataChanged() {
    invalidateLocations();
    eventBus.fire(AddressMetadataChangedEvent());
  }

  void invalidateLocations() {
    _sortedCountries = null;
    _sortedStates = null;
    _sortedPlaces = null;

    invalidateCountryFilterSummary();
    invalidateStateFilterSummary();
    invalidatePlaceFilterSummary();

    eventBus.fire(CountriesChangedEvent());
    eventBus.fire(StatesChangedEvent());
    eventBus.fire(PlacesChangedEvent());
  }

  void _computeLocations() {
    final locations = visibleEntries.map((entry) => entry.addressDetails).nonNulls.toSet();

    _sortedCountries = List.unmodifiable(
      _getAreaByCode(
        locations: locations,
        getCode: (v) => v.countryCode,
        getName: (v) => v.countryName,
      ),
    );
    _sortedStates = List.unmodifiable(
      _getAreaByCode(
        locations: locations,
        getCode: (v) => v.stateCode,
        getName: (v) => v.stateName,
      ),
    );
    _sortedPlaces = List.unmodifiable(locations.map((v) => v.place).nonNulls.where((v) => v.isNotEmpty).toSet().toList()..sort(compareAsciiUpperCase));
  }

  // the same country/state code could be found with different country/state names
  // e.g. if the locale changed between geocoding calls
  // so we merge countries/states by code, keeping only one name for each code
  List<String> _getAreaByCode({
    required Set<AddressDetails> locations,
    required String? Function(AddressDetails address) getCode,
    required String? Function(AddressDetails address) getName,
  }) {
    final namesByCode = Map.fromEntries(
      locations.map((address) {
        final code = getCode(address);
        if (code == null || code.isEmpty) return null;
        return MapEntry(code, getName(address));
      }).nonNulls,
    );
    return namesByCode.entries.map((kv) {
      final code = kv.key;
      final name = kv.value;
      return '${name != null && name.isNotEmpty ? name : code}${LocationFilter.locationSeparator}$code';
    }).toList()..sort(compareAsciiUpperCase);
  }
}

class AddressMetadataChangedEvent;
