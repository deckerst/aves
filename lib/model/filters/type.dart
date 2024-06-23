import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TypeFilter extends CollectionFilter {
  static const type = 'type';

  static const _animated = 'animated'; // subset of `image/gif` and `image/webp`
  static const _geotiff = 'geotiff'; // subset of `image/tiff`
  static const _hdr = 'hdr'; // subset of `image/jpeg`
  static const _motionPhoto = 'motion_photo'; // subset of images (jpeg, heic)
  static const _panorama = 'panorama'; // subset of images
  static const _raw = 'raw'; // specific image formats
  static const _sphericalVideo = 'spherical_video'; // subset of videos

  final String itemType;
  late final IconData _icon;
  late final EntryFilter _test;

  static final animated = TypeFilter._private(_animated);
  static final geotiff = TypeFilter._private(_geotiff);
  static final hdr = TypeFilter._private(_hdr);
  static final motionPhoto = TypeFilter._private(_motionPhoto);
  static final panorama = TypeFilter._private(_panorama);
  static final raw = TypeFilter._private(_raw);
  static final sphericalVideo = TypeFilter._private(_sphericalVideo);

  @override
  List<Object?> get props => [itemType, reversed];

  TypeFilter._private(this.itemType, {super.reversed = false}) {
    switch (itemType) {
      case _animated:
        _test = (entry) => entry.isAnimated;
        _icon = AIcons.animated;
      case _geotiff:
        _test = (entry) => entry.isGeotiff;
        _icon = AIcons.geo;
      case _hdr:
        _test = (entry) => entry.isHdr;
        _icon = AIcons.hdr;
      case _motionPhoto:
        _test = (entry) => entry.isMotionPhoto;
        _icon = AIcons.motionPhoto;
      case _panorama:
        _test = (entry) => entry.isImage && entry.is360;
        _icon = AIcons.panorama;
      case _raw:
        _test = (entry) => entry.isRaw;
        _icon = AIcons.raw;
      case _sphericalVideo:
        _test = (entry) => entry.isVideo && entry.is360;
        _icon = AIcons.sphericalVideo;
    }
  }

  factory TypeFilter.fromMap(Map<String, dynamic> json) {
    return TypeFilter._private(
      json['itemType'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'itemType': itemType,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => itemType;

  @override
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (itemType) {
      _animated => l10n.filterTypeAnimatedLabel,
      _geotiff => l10n.filterTypeGeotiffLabel,
      _hdr => 'HDR',
      _motionPhoto => l10n.filterTypeMotionPhotoLabel,
      _panorama => l10n.filterTypePanoramaLabel,
      _raw => l10n.filterTypeRawLabel,
      _sphericalVideo => l10n.filterTypeSphericalVideoLabel,
      _ => itemType,
    };
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(_icon, size: size);

  @override
  Future<Color> color(BuildContext context) {
    final colors = context.read<AvesColorsData>();
    switch (itemType) {
      case _animated:
        return SynchronousFuture(colors.animated);
      case _geotiff:
        return SynchronousFuture(colors.geotiff);
      case _motionPhoto:
        return SynchronousFuture(colors.motionPhoto);
      case _panorama:
        return SynchronousFuture(colors.panorama);
      case _raw:
        return SynchronousFuture(colors.raw);
      case _sphericalVideo:
        return SynchronousFuture(colors.sphericalVideo);
    }
    return super.color(context);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$itemType';
}
