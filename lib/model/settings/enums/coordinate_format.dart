import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/calendar/aves_locale.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

extension ExtraCoordinateFormat on CoordinateFormat {
  static const _separator = ', ';

  String format(BuildContext context, LatLng latLng, {bool minuteSecondPadding = false, int? dmsSecondDecimals}) {
    final text = formatWithoutDirectionality(settings.avesLocale, context.l10n, latLng, minuteSecondPadding: minuteSecondPadding, dmsSecondDecimals: dmsSecondDecimals);
    return context.applyDirectionality(text);
  }

  String formatWithoutDirectionality(AvesLocale locale, AppLocalizations l10n, LatLng latLng, {bool minuteSecondPadding = false, int? dmsSecondDecimals}) {
    switch (this) {
      case .dms:
        return toDMS(locale, l10n, latLng, minuteSecondPadding: minuteSecondPadding, secondDecimals: dmsSecondDecimals ?? 2).join(_separator);
      case .ddm:
        return toDDM(locale, l10n, latLng, minutePadding: minuteSecondPadding, minuteDecimals: dmsSecondDecimals ?? 4).join(_separator);
      case .decimal:
        return _toDecimal(locale, latLng).join(_separator);
    }
  }

  // returns coordinates formatted as DMS, e.g. ['41° 24′ 12.2″ N', '2° 10′ 26.5″ E']
  static List<String> toDMS(AvesLocale locale, AppLocalizations l10n, LatLng latLng, {bool minuteSecondPadding = false, int secondDecimals = 2}) {
    final lat = latLng.latitude;
    final lng = latLng.longitude;
    final latSexa = _decimal2sexagesimal(lat, minuteSecondPadding, secondDecimals, locale);
    final lngSexa = _decimal2sexagesimal(lng, minuteSecondPadding, secondDecimals, locale);
    return [
      l10n.coordinateDms(latSexa, lat < 0 ? l10n.coordinateDmsSouth : l10n.coordinateDmsNorth),
      l10n.coordinateDms(lngSexa, lng < 0 ? l10n.coordinateDmsWest : l10n.coordinateDmsEast),
    ];
  }

  // returns coordinates formatted as DDM, e.g. ['41° 24.2028′ N', '2° 10.4418′ E']
  static List<String> toDDM(AvesLocale locale, AppLocalizations l10n, LatLng latLng, {bool minutePadding = false, int minuteDecimals = 4}) {
    final lat = latLng.latitude;
    final lng = latLng.longitude;
    final latSexa = _decimal2ddm(lat, minutePadding, minuteDecimals, locale);
    final lngSexa = _decimal2ddm(lng, minutePadding, minuteDecimals, locale);
    return [
      l10n.coordinateDms(latSexa, lat < 0 ? l10n.coordinateDmsSouth : l10n.coordinateDmsNorth),
      l10n.coordinateDms(lngSexa, lng < 0 ? l10n.coordinateDmsWest : l10n.coordinateDmsEast),
    ];
  }

  static String _decimal2sexagesimal(
    double degDecimal,
    bool minuteSecondPadding,
    int secondDecimals,
    AvesLocale locale,
  ) {
    final degAbs = degDecimal.abs();
    final deg = degAbs.toInt();
    final minDecimal = (degAbs - deg) * 60;
    final min = minDecimal.toInt();
    final sec = (minDecimal - min) * 60;

    final degText = locale.numberFormat('0').format(deg);
    final minText = locale.numberFormat('0' * (minuteSecondPadding ? 2 : 1)).format(min);
    final secText = locale.numberFormat('${'0' * (minuteSecondPadding ? 2 : 1)}${secondDecimals > 0 ? '.${'0' * secondDecimals}' : ''}').format(sec);

    return '$degText° $minText′ $secText″';
  }

  static String _decimal2ddm(
    double degDecimal,
    bool minutePadding,
    int minuteDecimals,
    AvesLocale locale,
  ) {
    final degAbs = degDecimal.abs();
    final deg = degAbs.toInt();
    final min = (degAbs - deg) * 60;

    final degText = locale.numberFormat('0').format(deg);
    final minText = locale.numberFormat('${'0' * (minutePadding ? 2 : 1)}${minuteDecimals > 0 ? '.${'0' * minuteDecimals}' : ''}').format(min);

    return '$degText° $minText′';
  }

  static List<String> _toDecimal(AvesLocale locale, LatLng latLng) {
    final coordinateFormatter = locale.numberFormat('0.000000°');
    return [
      coordinateFormatter.format(latLng.latitude),
      coordinateFormatter.format(latLng.longitude),
    ];
  }
}
