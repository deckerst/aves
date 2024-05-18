import 'package:aves/l10n/l10n.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

extension ExtraCoordinateFormat on CoordinateFormat {
  static const _separator = ', ';

  String format(BuildContext context, LatLng latLng, {bool minuteSecondPadding = false, int dmsSecondDecimals = 2}) {
    final text = formatWithoutDirectionality(context.l10n, latLng, minuteSecondPadding: minuteSecondPadding, dmsSecondDecimals: dmsSecondDecimals);
    return context.applyDirectionality(text);
  }

  String formatWithoutDirectionality(AppLocalizations l10n, LatLng latLng, {bool minuteSecondPadding = false, int dmsSecondDecimals = 2}) {
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
    final latSexa = _decimal2sexagesimal(lat, minuteSecondPadding, secondDecimals, locale);
    final lngSexa = _decimal2sexagesimal(lng, minuteSecondPadding, secondDecimals, locale);
    return [
      l10n.coordinateDms(latSexa, lat < 0 ? l10n.coordinateDmsSouth : l10n.coordinateDmsNorth),
      l10n.coordinateDms(lngSexa, lng < 0 ? l10n.coordinateDmsWest : l10n.coordinateDmsEast),
    ];
  }

  static String _decimal2sexagesimal(
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

    final degText = NumberFormat('0', locale).format(deg);
    final minText = NumberFormat('0' * (minuteSecondPadding ? 2 : 1), locale).format(min);
    final secText = NumberFormat('${'0' * (minuteSecondPadding ? 2 : 1)}${secondDecimals > 0 ? '.${'0' * secondDecimals}' : ''}', locale).format(sec);

    return '$degText° $minText′ $secText″';
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
