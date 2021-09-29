import 'dart:math';

import 'package:latlong2/latlong.dart';

LatLng getLatLngCenter(List<LatLng> points) {
  double x = 0;
  double y = 0;
  double z = 0;

  points.forEach((point) {
    final lat = point.latitudeInRad;
    final lng = point.longitudeInRad;
    x += cos(lat) * cos(lng);
    y += cos(lat) * sin(lng);
    z += sin(lat);
  });

  final pointCount = points.length;
  x /= pointCount;
  y /= pointCount;
  z /= pointCount;

  final lng = atan2(y, x);
  final hyp = sqrt(x * x + y * y);
  final lat = atan2(z, hyp);
  return LatLng(radianToDeg(lat), radianToDeg(lng));
}
