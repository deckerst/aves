import 'package:aves/l10n/l10n.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'enums.dart';

extension ExtraCoordinateFormat on CoordinateFormat {
  String getName(BuildContext context) {
    switch (this) {
      case CoordinateFormat.dms:
        return context.l10n.coordinateFormatDms;
      case CoordinateFormat.decimal:
        return context.l10n.coordinateFormatDecimal;
    }
  }

  static const _separator = ', ';

  String format(AppLocalizations l10n, LatLng latLng, {bool minuteSecondPadding = false, int dmsSecondDecimals = 2}) {
    switch (this) {
      case CoordinateFormat.dms:
        return toDMS(l10n, latLng, minuteSecondPadding: minuteSecondPadding, secondDecimals: dmsSecondDecimals).join(_separator);
      case CoordinateFormat.decimal:
        return _toDecimal(l10n, latLng).join(_separator);
    }
  }

  // returns coordinates formatted as DMS, e.g. ['41° 24′ 12.2″ N', '2° 10′ 26.5″ E']
  static List<String> toDMS(AppLocalizations l10n, LatLng latLng, {bool minuteSecondPadding = false, int secondDecimals = 2}) {
    final locale = l10n.localeName;
    final lat = latLng.latitude;
    final lng = latLng.longitude;
    final latSexa = GeoUtils.decimal2sexagesimal(lat, minuteSecondPadding, secondDecimals, locale);
    final lngSexa = GeoUtils.decimal2sexagesimal(lng, minuteSecondPadding, secondDecimals, locale);
    return [
      l10n.coordinateDms(latSexa, lat < 0 ? l10n.coordinateDmsSouth : l10n.coordinateDmsNorth),
      l10n.coordinateDms(lngSexa, lng < 0 ? l10n.coordinateDmsWest : l10n.coordinateDmsEast),
    ];
  }

  static List<String> _toDecimal(AppLocalizations l10n, LatLng latLng) {
    final locale = l10n.localeName;
    final formatter = NumberFormat('0.000000°', locale);
    return [
      formatter.format(latLng.latitude),
      formatter.format(latLng.longitude),
    ];
  }
}
