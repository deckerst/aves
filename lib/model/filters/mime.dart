import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  // fake mime type
  static const animated = 'aves/animated'; // subset of `image/gif` and `image/webp`
  static const panorama = 'aves/panorama'; // subset of images
  static const sphericalVideo = 'aves/spherical_video'; // subset of videos
  static const geotiff = 'aves/geotiff'; // subset of `image/tiff`

  final String mime;
  bool Function(ImageEntry) _filter;
  String _label;
  IconData _icon;

  MimeFilter(this.mime) {
    var lowMime = mime.toLowerCase();
    if (mime == animated) {
      _filter = (entry) => entry.isAnimated;
      _label = 'Animated';
      _icon = AIcons.animated;
    } else if (mime == panorama) {
      _filter = (entry) => entry.isImage && entry.is360;
      _label = 'Panorama';
      _icon = AIcons.threesixty;
    } else if (mime == sphericalVideo) {
      _filter = (entry) => entry.isVideo && entry.is360;
      _label = '360° Video';
      _icon = AIcons.threesixty;
    } else if (mime == geotiff) {
      _filter = (entry) => entry.isGeotiff;
      _label = 'GeoTIFF';
      _icon = AIcons.geo;
    } else if (lowMime.endsWith('/*')) {
      lowMime = lowMime.substring(0, lowMime.length - 2);
      _filter = (entry) => entry.mimeType.startsWith(lowMime);
      if (lowMime == 'video') {
        _label = 'Video';
        _icon = AIcons.video;
      } else if (lowMime == 'image') {
        _label = 'Image';
        _icon = AIcons.image;
      }
      _label ??= lowMime.split('/')[0].toUpperCase();
    } else {
      _filter = (entry) => entry.mimeType == lowMime;
      _label = MimeUtils.displayType(lowMime);
    }
    _icon ??= AIcons.vector;
  }

  MimeFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['mime'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'mime': mime,
      };

  @override
  bool filter(ImageEntry entry) => _filter(entry);

  @override
  String get label => _label;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(_icon, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MimeFilter && other.mime == mime;
  }

  @override
  int get hashCode => hashValues(type, mime);

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{mime=$mime}';
  }
}
