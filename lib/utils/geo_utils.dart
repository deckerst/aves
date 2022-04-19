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

  // cf https://epsg.io/EPSGCODE.proj4
  // cf https://github.com/stevage/epsg
  // cf https://github.com/maRci002/proj4dart/blob/master/test/data/all_proj4_defs.dart
  static String? epsgToProj4(int? epsg) {
    // `32767` refers to user defined values
    if (epsg == null || epsg == 32767) return null;

    if (3038 <= epsg && epsg <= 3051) {
      // ETRS89 / UTM (N-E)
      final zone = epsg - 3012;
      return '+proj=utm +zone=$zone +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
    } else if (26700 <= epsg && epsg <= 26799) {
      // US State Plane (NAD27): 267xx/320xx
      if (26703 <= epsg && epsg <= 26722) {
        final zone = epsg - 26700;
        return '+proj=utm +zone=$zone +datum=NAD27 +units=m +no_defs';
      }
      // NAD27 datum requires loading `nadgrids` for accurate transformation:
      // cf https://github.com/proj4js/proj4js/pull/363
      // cf https://github.com/maRci002/proj4dart/issues/8
      if (epsg == 26746) {
        // NAD27 / California zone VI
        return '+proj=lcc +lat_1=33.88333333333333 +lat_2=32.78333333333333 +lat_0=32.16666666666666 +lon_0=-116.25 +x_0=609601.2192024384 +y_0=0 +datum=NAD27 +units=us-ft +no_defs';
      } else if (epsg == 26771) {
        // NAD27 / Illinois East
        return '+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=152400.3048006096 +y_0=0 +datum=NAD27 +units=us-ft +no_defs';
      }
    } else if ((26900 <= epsg && epsg <= 26999) || (32100 <= epsg && epsg <= 32199)) {
      // US State Plane (NAD83): 269xx/321xx
      if (epsg == 26966) {
        // NAD83 Georgia East
        return '+proj=tmerc +lat_0=30 +lon_0=-82.16666666666667 +k=0.9999 +x_0=200000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
      }
    } else if (32200 <= epsg && epsg <= 32299) {
      // WGS72 / UTM northern hemisphere: 322zz where zz is UTM zone number
      final zone = epsg - 32200;
      return '+proj=utm +zone=$zone +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +units=m +no_defs';
    } else if (32300 <= epsg && epsg <= 32399) {
      // WGS72 / UTM southern hemisphere: 323zz where zz is UTM zone number
      final zone = epsg - 32300;
      return '+proj=utm +zone=$zone +south +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +units=m +no_defs';
    } else if (32400 <= epsg && epsg <= 32460) {
      // WGS72BE / UTM northern hemisphere: 324zz where zz is UTM zone number
      final zone = epsg - 32400;
      return '+proj=utm +zone=$zone +ellps=WGS72 +towgs84=0,0,1.9,0,0,0.814,-0.38 +units=m +no_defs';
    } else if (32500 <= epsg && epsg <= 32599) {
      // WGS72BE / UTM southern hemisphere: 325zz where zz is UTM zone number
      final zone = epsg - 32500;
      return '+proj=utm +zone=$zone +south +ellps=WGS72 +towgs84=0,0,1.9,0,0,0.814,-0.38 +units=m +no_defs';
    } else if (32600 <= epsg && epsg <= 32699) {
      // WGS84 / UTM northern hemisphere: 326zz where zz is UTM zone number
      final zone = epsg - 32600;
      return '+proj=utm +zone=$zone +datum=WGS84 +units=m +no_defs';
    } else if (32700 <= epsg && epsg <= 32799) {
      // WGS84 / UTM southern hemisphere: 327zz where zz is UTM zone number
      final zone = epsg - 32700;
      return '+proj=utm +zone=$zone +south +datum=WGS84 +units=m +no_defs';
    }

    return null;
  }
}

// cf https://www.maptiler.com/google-maps-coordinates-tile-bounds-projection/
class MapServiceHelper {
  final int tileSize;
  late final double initialResolution, originShift;

  MapServiceHelper(this.tileSize) {
    initialResolution = 2 * pi * 6378137 / tileSize;
    originShift = 2 * pi * 6378137 / 2.0;
  }

  int matrixSize(int zoomLevel) {
    return 1 << zoomLevel;
  }

  Point<double> pixelsToMeters(double px, double py, int zoomLevel) {
    double res = resolution(zoomLevel);
    double mx = px * res - originShift;
    double my = -py * res + originShift;
    return Point(mx, my);
  }

  double resolution(int zoomLevel) {
    return initialResolution / matrixSize(zoomLevel);
  }

  Point<double> tileTopLeft(int tx, int ty, int zoomLevel) {
    final px = tx * tileSize;
    final py = ty * tileSize;
    return pixelsToMeters(px.toDouble(), py.toDouble(), zoomLevel);
  }
}
