import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TypeFilter extends CollectionFilter {
  static const type = 'type';

  static const animated = 'animated'; // subset of `image/gif` and `image/webp`
  static const geotiff = 'geotiff'; // subset of `image/tiff`
  static const panorama = 'panorama'; // subset of images
  static const sphericalVideo = 'spherical_video'; // subset of videos

  final String itemType;
  EntryFilter _test;
  String _label;
  IconData _icon;

  TypeFilter(this.itemType) {
    if (itemType == animated) {
      _test = (entry) => entry.isAnimated;
      _label = 'Animated';
      _icon = AIcons.animated;
    } else if (itemType == panorama) {
      _test = (entry) => entry.isImage && entry.is360;
      _label = 'Panorama';
      _icon = AIcons.threesixty;
    } else if (itemType == sphericalVideo) {
      _test = (entry) => entry.isVideo && entry.is360;
      _label = '360° Video';
      _icon = AIcons.threesixty;
    } else if (itemType == geotiff) {
      _test = (entry) => entry.isGeotiff;
      _label = 'GeoTIFF';
      _icon = AIcons.geo;
    }
  }

  TypeFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['itemType'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'itemType': itemType,
      };

  @override
  EntryFilter get test => _test;

  @override
  String get label => _label;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(_icon, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TypeFilter && other.itemType == itemType;
  }

  @override
  int get hashCode => hashValues(type, itemType);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{itemType=$itemType}';
}
