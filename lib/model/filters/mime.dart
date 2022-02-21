import 'package:aves/model/filters/filters.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  final String mime;
  late final EntryFilter _test;
  late final String _label;
  late final IconData _icon;
  late final Color _color;

  static final image = MimeFilter(MimeTypes.anyImage);
  static final video = MimeFilter(MimeTypes.anyVideo);

  @override
  List<Object?> get props => [mime];

  MimeFilter(this.mime) {
    IconData? icon;
    Color? color;
    var lowMime = mime.toLowerCase();
    if (lowMime.endsWith('/*')) {
      lowMime = lowMime.substring(0, lowMime.length - 2);
      _test = (entry) => entry.mimeType.startsWith(lowMime);
      _label = lowMime.toUpperCase();
      if (mime == MimeTypes.anyImage) {
        icon = AIcons.image;
        color = AColors.image;
      } else if (mime == MimeTypes.anyVideo) {
        icon = AIcons.video;
        color = AColors.video;
      }
    } else {
      _test = (entry) => entry.mimeType == lowMime;
      _label = MimeUtils.displayType(lowMime);
    }
    _icon = icon ?? AIcons.vector;
    _color = color ?? stringToColor(_label);
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
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(_icon, size: size);

  @override
  Future<Color> color(BuildContext context) => SynchronousFuture(_color);

  @override
  String get category => type;

  @override
  String get key => '$type-$mime';
}
