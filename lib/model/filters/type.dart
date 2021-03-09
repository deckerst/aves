import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
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
  IconData _icon;

  TypeFilter(this.itemType) {
    switch (itemType) {
      case animated:
        _test = (entry) => entry.isAnimated;
        _icon = AIcons.animated;
        break;
      case panorama:
        _test = (entry) => entry.isImage && entry.is360;
        _icon = AIcons.threesixty;
        break;
      case sphericalVideo:
        _test = (entry) => entry.isVideo && entry.is360;
        _icon = AIcons.threesixty;
        break;
      case geotiff:
        _test = (entry) => entry.isGeotiff;
        _icon = AIcons.geo;
        break;
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
  String get universalLabel => itemType;

  @override
  String getLabel(BuildContext context) {
    switch (itemType) {
      case animated:
        return context.l10n.filterTypeAnimatedLabel;
      case panorama:
        return context.l10n.filterTypePanoramaLabel;
      case sphericalVideo:
        return context.l10n.filterTypeSphericalVideoLabel;
      case geotiff:
        return context.l10n.filterTypeGeotiffLabel;
      default:
        return itemType;
    }
  }

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(_icon, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$itemType';

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
