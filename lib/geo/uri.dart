import 'package:latlong2/latlong.dart';

// e.g. `geo:44.4361283,26.1027248?z=4.0(Bucharest)`
// cf https://en.wikipedia.org/wiki/Geo_URI_scheme
// cf https://developer.android.com/guide/components/intents-common#ViewMap
(LatLng, double?)? parseGeoUri(String? uri) {
  if (uri != null) {
    final geoUri = Uri.tryParse(uri);
    if (geoUri != null) {
      final coordinates = geoUri.path.split(',');
      if (coordinates.length == 2) {
        final lat = double.tryParse(coordinates[0]);
        final lon = double.tryParse(coordinates[1]);
        if (lat != null && lon != null) {
          double? zoom;
          final zoomString = geoUri.queryParameters['z'];
          if (zoomString != null) {
            zoom = double.tryParse(zoomString);
          }
          return (LatLng(lat, lon), zoom);
        }
      }
    }
  }
  return null;
}
