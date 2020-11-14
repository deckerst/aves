import 'dart:math';

const double _piOver180 = pi / 180.0;

final double log2 = log(2);

double toDegrees(num radians) => radians / _piOver180;

double toRadians(num degrees) => degrees * _piOver180;

int highestPowerOf2(num x) => x < 1 ? 0 : pow(2, (log(x) / log2).floor());
