import 'dart:math';

import 'package:aves/utils/math_utils.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class GeoUtils {
  static String _decimal2sexagesimal(final double degDecimal, final bool minuteSecondPadding, final int secondDecimals) {
    List<int> _split(final double value) {
      // NumberFormat is necessary to create digit after comma if the value
      // has no decimal point (only necessary for browser)
      final tmp = NumberFormat('0.0#####').format(roundToPrecision(value, decimals: 10)).split('.');
      return <int>[
        int.parse(tmp[0]).abs(),
        int.parse(tmp[1]),
      ];
    }

    final deg = _split(degDecimal)[0];
    final minDecimal = (degDecimal.abs() - deg) * 60;
    final min = _split(minDecimal)[0];
    final sec = (minDecimal - min) * 60;

    final secRounded = roundToPrecision(sec, decimals: secondDecimals);
    var minText = '$min';
    var secText = secRounded.toStringAsFixed(secondDecimals);
    if (minuteSecondPadding) {
      minText = minText.padLeft(2, '0');
      secText = secText.padLeft(secondDecimals > 0 ? 3 + secondDecimals : 2, '0');
    }

    return '$deg° $minText′ $secText″';
  }

  // returns coordinates formatted as DMS, e.g. ['41° 24′ 12.2″ N', '2° 10′ 26.5″ E']
  static List<String> toDMS(LatLng latLng, {bool minuteSecondPadding = false, int secondDecimals = 2}) {
    final lat = latLng.latitude;
    final lng = latLng.longitude;
    return [
      '${_decimal2sexagesimal(lat, minuteSecondPadding, secondDecimals)} ${lat < 0 ? 'S' : 'N'}',
      '${_decimal2sexagesimal(lng, minuteSecondPadding, secondDecimals)} ${lng < 0 ? 'W' : 'E'}',
    ];
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
