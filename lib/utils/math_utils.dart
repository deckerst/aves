import 'dart:math';

import 'package:flutter/foundation.dart';

final double _log2 = log(2);
const double _piOver180 = pi / 180.0;

double toDegrees(num radians) => radians / _piOver180;

double toRadians(num degrees) => degrees * _piOver180;

int highestPowerOf2(num x) => x < 1 ? 0 : pow(2, (log(x) / _log2).floor());

double roundToPrecision(final double value, {@required final int decimals}) => (value * pow(10, decimals)).round() / pow(10, decimals);

// e.g. x=12345, precision=3 should return 13000
int ceilBy(num x, int precision) {
  final factor = pow(10, precision);
  return (x / factor).ceil() * factor;
}
