import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class CoordinateFilter extends CollectionFilter {
  static const type = 'coordinate';

  final LatLng sw;
  final LatLng ne;
  final bool minuteSecondPadding;
  late final EntryPredicate _test;

  @override
  List<Object?> get props => [sw, ne, reversed];

  CoordinateFilter(this.sw, this.ne, {this.minuteSecondPadding = false, super.reversed = false}) {
    _test = (entry) => GeoUtils.contains(sw, ne, entry.latLng);
  }

  factory CoordinateFilter.fromMap(Map<String, Object?> json) {
    return CoordinateFilter(
      LatLng.fromJson(json['sw'] as Map<String, Object?>),
      LatLng.fromJson(json['ne'] as Map<String, Object?>),
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
    'type': type,
    'sw': sw.toJson(),
    'ne': ne.toJson(),
    if (reversed) 'reversed': reversed,
  };

  @override
  EntryPredicate get positiveTest => _test;

  String _formatBounds(String Function(LatLng latLng) s) => '${s(ne)}\n${s(sw)}';

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel {
    return _formatBounds(
      (latLng) => CoordinateFormat.decimal.formatWithoutDirectionality(
        lookupAppLocalizations(AppLocalizations.supportedLocales.first),
        latLng,
        minuteSecondPadding: minuteSecondPadding,
        dmsSecondDecimals: 0,
      ),
    );
  }

  @override
  String getLabel(BuildContext context) {
    return _formatBounds((latLng) {
      final format = settings.coordinateFormat;
      return format.format(
        context,
        latLng,
        minuteSecondPadding: minuteSecondPadding,
        dmsSecondDecimals: format == CoordinateFormat.ddm ? 2 : 0,
      );
    });
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.geoBounds, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$sw-$ne';
}
