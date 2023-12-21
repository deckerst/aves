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
  late final EntryFilter _test;

  @override
  List<Object?> get props => [sw, ne, reversed];

  CoordinateFilter(this.sw, this.ne, {this.minuteSecondPadding = false, super.reversed = false}) {
    _test = (entry) => GeoUtils.contains(sw, ne, entry.latLng);
  }

  factory CoordinateFilter.fromMap(Map<String, dynamic> json) {
    return CoordinateFilter(
      LatLng.fromJson(json['sw']),
      LatLng.fromJson(json['ne']),
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'sw': sw.toJson(),
        'ne': ne.toJson(),
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  String _formatBounds(String Function(LatLng latLng) s) => '${s(ne)}\n${s(sw)}';

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel {
    return _formatBounds((latLng) => CoordinateFormat.decimal.formatWithoutDirectionality(
          lookupAppLocalizations(AppLocalizations.supportedLocales.first),
          latLng,
          minuteSecondPadding: minuteSecondPadding,
          dmsSecondDecimals: 0,
        ));
  }

  @override
  String getLabel(BuildContext context) {
    return _formatBounds((latLng) => settings.coordinateFormat.format(
          context,
          latLng,
          minuteSecondPadding: minuteSecondPadding,
          dmsSecondDecimals: 0,
        ));
  }

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.geoBounds, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$sw-$ne';
}
