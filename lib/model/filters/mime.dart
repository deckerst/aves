import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/mime_types.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  final String mime;
  bool Function(ImageEntry) _filter;
  String _label;
  IconData _icon;

  MimeFilter(this.mime) {
    var lowMime = mime.toLowerCase();
    if (lowMime.endsWith('/*')) {
      lowMime = lowMime.substring(0, lowMime.length - 2);
      _filter = (entry) => entry.mimeType.startsWith(lowMime);
      if (lowMime == 'video') {
        _label = 'Video';
        _icon = OMIcons.movie;
      }
      _label ??= lowMime.split('/')[0].toUpperCase();
    } else {
      _filter = (entry) => entry.mimeType == lowMime;
      if (lowMime == MimeTypes.MIME_GIF) {
        _icon = OMIcons.gif;
      } else if (lowMime == MimeTypes.MIME_SVG) {
        _label = 'SVG';
      }
      _label ??= lowMime.split('/')[1].toUpperCase();
    }
    _icon ??= OMIcons.code;
  }

  @override
  bool filter(ImageEntry entry) => _filter(entry);

  @override
  String get label => _label;

  @override
  Widget iconBuilder(context, size) => Icon(_icon, size: size);

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
