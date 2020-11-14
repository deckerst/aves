import 'dart:math';

import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

String _decimal2sexagesimal(final double degDecimal) {
  double _round(final double value, {final int decimals = 6}) => (value * pow(10, decimals)).round() / pow(10, decimals);

  List<int> _split(final double value) {
    // NumberFormat is necessary to create digit after comma if the value
    // has no decimal point (only necessary for browser)
    final tmp = NumberFormat('0.0#####').format(_round(value, decimals: 10)).split('.');
    return <int>[
      int.parse(tmp[0]).abs(),
      int.parse(tmp[1]),
    ];
  }

  final deg = _split(degDecimal)[0];
  final minDecimal = (degDecimal.abs() - deg) * 60;
  final min = _split(minDecimal)[0];
  final sec = (minDecimal - min) * 60;

  return '$deg° $min′ ${_round(sec, decimals: 2).toStringAsFixed(2)}″';
}

// return coordinates formatted as DMS, e.g. ['41° 24′ 12.2″ N', '2° 10′ 26.5″ E']
List<String> toDMS(Tuple2<double, double> latLng) {
  if (latLng == null) return [];
  final lat = latLng.item1;
  final lng = latLng.item2;
  return [
    '${_decimal2sexagesimal(lat)} ${lat < 0 ? 'S' : 'N'}',
    '${_decimal2sexagesimal(lng)} ${lng < 0 ? 'W' : 'E'}',
  ];
}
