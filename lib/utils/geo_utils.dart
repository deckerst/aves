import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

// adapted from Mike Mitterer's dart-latlong library
String _decimal2sexagesimal(final double dec) {
  double _round(final double value, {final int decimals = 6}) => (value * math.pow(10, decimals)).round() / math.pow(10, decimals);

  List<int> _split(final double value) {
    // NumberFormat is necessary to create digit after comma if the value
    // has no decimal point (only necessary for browser)
    final List<String> tmp = NumberFormat('0.0#####').format(_round(value, decimals: 10)).split('.');
    return <int>[
      int.parse(tmp[0]).abs(),
      int.parse(tmp[1])
    ];
  }

  final List<int> parts = _split(dec);
  final int integerPart = parts[0];
  final int fractionalPart = parts[1];

  final int deg = integerPart;
  final double min = double.parse('0.$fractionalPart') * 60;

  final List<int> minParts = _split(min);
  final int minFractionalPart = minParts[1];

  final double sec = (double.parse('0.$minFractionalPart') * 60);

  return '$deg° ${min.floor()}′ ${_round(sec, decimals: 2).toStringAsFixed(2)}″';
}

// return coordinates formatted as DMS, e.g. ['41°24′12.2″ N', '2°10′26.5″E']
List<String> toDMS(Tuple2<double, double> latLng) {
  if (latLng == null) return [];
  final lat = latLng.item1;
  final lng = latLng.item2;
  return [
    '${_decimal2sexagesimal(lat)} ${lat < 0 ? 'S' : 'N'}',
    '${_decimal2sexagesimal(lng)} ${lng < 0 ? 'W' : 'E'}'
  ];
}
