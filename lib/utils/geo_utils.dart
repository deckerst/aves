import 'dart:math';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class GeoUtils {
  static String decimal2sexagesimal(
    double degDecimal,
    bool minuteSecondPadding,
    int secondDecimals,
    String locale,
  ) {
    final degAbs = degDecimal.abs();
    final deg = degAbs.toInt();
    final minDecimal = (degAbs - deg) * 60;
    final min = minDecimal.toInt();
    final sec = (minDecimal - min) * 60;

    var minText = NumberFormat('0' * (minuteSecondPadding ? 2 : 1), locale).format(min);
    var secText = NumberFormat('${'0' * (minuteSecondPadding ? 2 : 1)}${secondDecimals > 0 ? '.${'0' * secondDecimals}' : ''}', locale).format(sec);

    return '$deg° $minText′ $secText″';
  }

  static LatLng getLatLngCenter(List<LatLng> points) {
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

  static bool contains(LatLng sw, LatLng ne, LatLng? point) {
    if (point == null) return false;
    final lat = point.latitude;
    final lng = point.longitude;
    final south = sw.latitude;
    final north = ne.latitude;
    final west = sw.longitude;
    final east = ne.longitude;
    return (south <= lat && lat <= north) && (west <= east ? (west <= lng && lng <= east) : (west <= lng || lng <= east));
  }
}
