import 'package:aves/geo/format.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'enums.dart';

extension ExtraCoordinateFormat on CoordinateFormat {
  String getName(BuildContext context) {
    switch (this) {
      case CoordinateFormat.dms:
        return context.l10n.coordinateFormatDms;
      case CoordinateFormat.decimal:
        return context.l10n.coordinateFormatDecimal;
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
