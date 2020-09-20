import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  // fake mime type
  static const animated = 'aves/animated'; // subset of `image/gif` and `image/webp`

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
      _label = displayType(lowMime);
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

  static String displayType(String mime) {
    return mime.toUpperCase().replaceFirst(RegExp('.*/(X-)?'), '').replaceFirst('+XML', '').replaceFirst('VND.', '');
  }

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
  int get hashCode => hashValues('MimeFilter', mime);
}
