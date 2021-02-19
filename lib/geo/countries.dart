import 'dart:async';

import 'package:aves/geo/topojson.dart';
import 'package:country_code/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';

final CountryTopology countryTopology = CountryTopology._private();

class CountryTopology {
  static const topoJsonAsset = 'assets/countries-50m.json';

  CountryTopology._private();

  Topology _topology;

  Future<Topology> getTopology() => _topology != null ? SynchronousFuture(_topology) : rootBundle.loadString(topoJsonAsset).then(TopoJson().parse);

  // return the country containing given coordinates
  Future<CountryCode> countryCode(LatLng position) async {
    return _countryOfNumeric(await numericCode(position));
  }

  // return the ISO 3166-1 numeric code of the country containing given coordinates
  Future<int> numericCode(LatLng position) async {
    final topology = await getTopology();
    if (topology == null) return null;

    final countries = (topology.objects['countries'] as GeometryCollection).geometries;
    return _getNumeric(topology, countries, position);
  }

  // return a map of the given positions by country
  Future<Map<CountryCode, Set<LatLng>>> countryCodeMap(Set<LatLng> positions) async {
    final numericMap = await numericCodeMap(positions);
    numericMap.remove(null);
    final codeMap = numericMap.map((key, value) {
      final code = _countryOfNumeric(key);
      return code == null ? null : MapEntry(code, value);
    });
    codeMap.remove(null);
    return codeMap;
  }

  // return a map of the given positions by the ISO 3166-1 numeric code of the country containing them
  Future<Map<int, Set<LatLng>>> numericCodeMap(Set<LatLng> positions) async {
    final topology = await getTopology();
    if (topology == null) return null;

    return compute(_isoNumericCodeMap, _IsoNumericCodeMapData(topology, positions));
  }

  static Future<Map<int, Set<LatLng>>> _isoNumericCodeMap(_IsoNumericCodeMapData data) async {
    try {
      final topology = data.topology;
      final countries = (topology.objects['countries'] as GeometryCollection).geometries;
      final byCode = <int, Set<LatLng>>{};
      for (final position in data.positions) {
        final code = _getNumeric(topology, countries, position);
        byCode[code] = (byCode[code] ?? {})..add(position);
      }
      return byCode;
    } catch (error, stack) {
      // an unhandled error in a spawn isolate would make the app crash
      debugPrint('failed to get country codes with error=$error\n$stack');
    }
    return null;
  }

  static int _getNumeric(Topology topology, List<Geometry> countries, LatLng position) {
    final point = [position.longitude, position.latitude];
    final hit = countries.firstWhere((country) => country.containsPoint(topology, point), orElse: () => null);
    final idString = (hit?.id as String);
    final code = idString == null ? null : int.tryParse(idString);
    return code;
  }

  static CountryCode _countryOfNumeric(int numeric) {
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
