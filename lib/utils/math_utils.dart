import 'dart:math';

const double _piOver180 = pi / 180.0;

double toDegrees(double radians) => radians / _piOver180;

double toRadians(double degrees) => degrees * _piOver180;
