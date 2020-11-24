import 'package:aves/utils/geo_utils.dart';
import 'package:latlong/latlong.dart';

enum CoordinateFormat { dms, decimal }

extension ExtraCoordinateFormat on CoordinateFormat {
  String get name {
    switch (this) {
      case CoordinateFormat.dms:
        return 'DMS';
      case CoordinateFormat.decimal:
        return 'Decimal degrees';
      default:
        return toString();
    }
  }

  String format(LatLng latLng) {
    switch (this) {
      case CoordinateFormat.dms:
        return toDMS(latLng).join(', ');
      case CoordinateFormat.decimal:
        return [latLng.latitude, latLng.longitude].map((n) => n.toStringAsFixed(6)).join(', ');
      default:
        return toString();
    }
  }
}
