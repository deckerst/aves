import 'dart:async';

import 'package:aves/geo/topojson.dart';
import 'package:collection/collection.dart';
import 'package:country_code/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

final CountryTopology countryTopology = CountryTopology._private();

class CountryTopology {
  static const topoJsonAsset = 'assets/countries-50m.json';

  CountryTopology._private();

  Topology? _topology;

  Future<Topology?> getTopology() => _topology != null ? SynchronousFuture(_topology) : rootBundle.loadString(topoJsonAsset).then(TopoJson().parse);

  // returns the country containing given coordinates
  Future<CountryCode?> countryCode(LatLng position) async {
    return _countryOfNumeric(await numericCode(position));
  }

  // returns the ISO 3166-1 numeric code of the country containing given coordinates
  Future<int?> numericCode(LatLng position) async {
    final topology = await getTopology();
    if (topology == null) return null;

    final countries = (topology.objects['countries'] as GeometryCollection).geometries;
    return _getNumeric(topology, countries, position);
  }

  // returns a map of the given positions by country
  Future<Map<CountryCode, Set<LatLng>>> countryCodeMap(Set<LatLng> positions) async {
    final numericMap = await numericCodeMap(positions);
    if (numericMap == null) return {};

    return Map.fromEntries(numericMap.entries.map((kv) {
      final code = _countryOfNumeric(kv.key);
      return code != null ? MapEntry(code, kv.value) : null;
    }).whereNotNull());
  }

  // returns a map of the given positions by the ISO 3166-1 numeric code of the country containing them
  Future<Map<int, Set<LatLng>>?> numericCodeMap(Set<LatLng> positions) async {
    final topology = await getTopology();
    if (topology == null) return null;

    return compute<_IsoNumericCodeMapData, Map<int, Set<LatLng>>>(_isoNumericCodeMap, _IsoNumericCodeMapData(topology, positions));
  }

  static Future<Map<int, Set<LatLng>>> _isoNumericCodeMap(_IsoNumericCodeMapData data) async {
    try {
      final topology = data.topology;
      final countries = (topology.objects['countries'] as GeometryCollection).geometries;
      final byCode = <int, Set<LatLng>>{};
      for (final position in data.positions) {
        final code = _getNumeric(topology, countries, position);
        if (code != null) {
          byCode[code] = (byCode[code] ?? {})..add(position);
        }
      }
      return byCode;
    } catch (error, stack) {
      // an unhandled error in a spawn isolate would make the app crash
      debugPrint('failed to get country codes with error=$error\n$stack');
    }
    return {};
  }

  static int? _getNumeric(Topology topology, List<Geometry> mruCountries, LatLng position) {
    final point = [position.longitude, position.latitude];
    final hit = mruCountries.firstWhereOrNull((country) => country.containsPoint(topology, point));
    if (hit == null) return null;

    // promote hit countries, assuming given positions are likely to come from the same countries
    if (mruCountries.first != hit) {
      mruCountries.remove(hit);
      mruCountries.insert(0, hit);
    }

    final idString = (hit.id as String?);
    final code = idString == null ? null : int.tryParse(idString);
    return code;
  }

  static CountryCode? _countryOfNumeric(int? numeric) {
    if (numeric == null) return null;
    try {
      return CountryCode.ofNumeric(numeric);
    } catch (error) {
      debugPrint('failed to find country for numeric=$numeric with error=$error');
    }
    return null;
  }
}

class _IsoNumericCodeMapData {
  Topology topology;
  Set<LatLng> positions;

  _IsoNumericCodeMapData(this.topology, this.positions);
}
