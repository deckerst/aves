import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CoordinateFilter extends CollectionFilter {
  static const type = 'coordinate';

  final LatLng sw;
  final LatLng ne;
  final bool minuteSecondPadding;

  @override
  List<Object?> get props => [sw, ne];

  const CoordinateFilter(this.sw, this.ne, {this.minuteSecondPadding = false});

  CoordinateFilter.fromMap(Map<String, dynamic> json)
      : this(
          LatLng.fromJson(json['sw']),
          LatLng.fromJson(json['ne']),
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'sw': sw.toJson(),
        'ne': ne.toJson(),
      };

  @override
  EntryFilter get test => (entry) => GeoUtils.contains(sw, ne, entry.latLng);

  String _formatBounds(CoordinateFormat format) {
    String s(LatLng latLng) => format.format(
          latLng,
          minuteSecondPadding: minuteSecondPadding,
          dmsSecondDecimals: 0,
        );
    return '${s(ne)}\n${s(sw)}';
  }

  @override
  String get universalLabel => _formatBounds(CoordinateFormat.decimal);

  @override
  String getLabel(BuildContext context) => _formatBounds(context.read<Settings>().coordinateFormat);

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(AIcons.geoBounds, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$sw-$ne';
}
