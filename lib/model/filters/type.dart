import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TypeFilter extends CollectionFilter {
  static const type = 'type';

  static const _animated = 'animated'; // subset of `image/gif` and `image/webp`
  static const _geotiff = 'geotiff'; // subset of `image/tiff`
  static const _motionPhoto = 'motion_photo'; // subset of `image/jpeg`
  static const _panorama = 'panorama'; // subset of images
  static const _sphericalVideo = 'spherical_video'; // subset of videos

  final String itemType;
  EntryFilter _test;
  IconData _icon;

  static final animated = TypeFilter._private(_animated);
  static final geotiff = TypeFilter._private(_geotiff);
  static final motionPhoto = TypeFilter._private(_motionPhoto);
  static final panorama = TypeFilter._private(_panorama);
  static final sphericalVideo = TypeFilter._private(_sphericalVideo);

  TypeFilter._private(this.itemType) {
    switch (itemType) {
      case _animated:
        _test = (entry) => entry.isAnimated;
        _icon = AIcons.animated;
        break;
      case _motionPhoto:
        _test = (entry) => entry.isMotionPhoto;
        _icon = AIcons.motionPhoto;
        break;
      case _panorama:
        _test = (entry) => entry.isImage && entry.is360;
        _icon = AIcons.threeSixty;
        break;
      case _sphericalVideo:
        _test = (entry) => entry.isVideo && entry.is360;
        _icon = AIcons.threeSixty;
        break;
      case _geotiff:
        _test = (entry) => entry.isGeotiff;
        _icon = AIcons.geo;
        break;
    }
  }

  TypeFilter.fromMap(Map<String, dynamic> json)
      : this._private(
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
      case _animated:
        return context.l10n.filterTypeAnimatedLabel;
      case _motionPhoto:
        return context.l10n.filterTypeMotionPhotoLabel;
      case _panorama:
        return context.l10n.filterTypePanoramaLabel;
      case _sphericalVideo:
        return context.l10n.filterTypeSphericalVideoLabel;
      case _geotiff:
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
