import 'package:aves/model/filters/filters.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  final String mime;
  EntryFilter _test;
  String _label;
  IconData _icon;

  MimeFilter(this.mime) {
    var lowMime = mime.toLowerCase();
    if (lowMime.endsWith('/*')) {
      lowMime = lowMime.substring(0, lowMime.length - 2);
      _test = (entry) => entry.mimeType.startsWith(lowMime);
      _label = lowMime.toUpperCase();
      if (mime == MimeTypes.anyImage) {
        _icon = AIcons.image;
      } else if (mime == MimeTypes.anyVideo) {
        _icon = AIcons.video;
      }
    } else {
      _test = (entry) => entry.mimeType == lowMime;
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
  EntryFilter get test => _test;

  @override
  String get universalLabel => _label;

  @override
  String getLabel(BuildContext context) {
    switch (mime) {
      case MimeTypes.anyImage:
        return context.l10n.filterMimeImageLabel;
      case MimeTypes.anyVideo:
        return context.l10n.filterMimeVideoLabel;
      default:
        return _label;
    }
  }

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(_icon, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$mime';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MimeFilter && other.mime == mime;
  }

  @override
  int get hashCode => hashValues(type, mime);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{mime=$mime}';
}
