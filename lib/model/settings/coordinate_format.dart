import 'package:aves/utils/geo_utils.dart';
import 'package:tuple/tuple.dart';

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

  String format(Tuple2<double, double> latLng) {
    switch (this) {
      case CoordinateFormat.dms:
        return toDMS(latLng).join(', ');
      case CoordinateFormat.decimal:
        return [latLng.item1, latLng.item2].map((n) => n.toStringAsFixed(6)).join(', ');
      default:
        return toString();
    }
  }
}
