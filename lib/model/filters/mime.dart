import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MimeFilter extends CollectionFilter {
  static const type = 'mime';

  final String mime;
  late final String _label;
  late final IconData _icon;
  late final EntryPredicate _test;

  static final image = MimeFilter(MimeTypes.anyImage);
  static final video = MimeFilter(MimeTypes.anyVideo);

  @override
  List<Object?> get props => [mime, reversed];

  MimeFilter(this.mime, {super.reversed = false}) {
    IconData? icon;
    var lowMime = mime.toLowerCase();
    if (lowMime.endsWith('/*')) {
      lowMime = lowMime.substring(0, lowMime.length - 2);
      _test = (entry) => entry.mimeType.startsWith(lowMime);
      _label = lowMime.toUpperCase();
      if (mime == MimeTypes.anyImage) {
        icon = AIcons.image;
      } else if (mime == MimeTypes.anyVideo) {
        icon = AIcons.video;
      }
    } else {
      _test = (entry) => entry.mimeType == lowMime;
      _label = MimeUtils.displayType(lowMime);
    }
    _icon = icon ?? AIcons.vector;
  }

  factory MimeFilter.fromMap(Map<String, dynamic> json) {
    return MimeFilter(
      json['mime'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'mime': mime,
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => _label;

  @override
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (mime) {
      MimeTypes.anyImage => l10n.filterMimeImageLabel,
      MimeTypes.anyVideo => l10n.filterMimeVideoLabel,
      _ => _label,
    };
  }

  @override
  String getTooltip(BuildContext context) {
    return '${getLabel(context)} ($mime)';
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(_icon, size: size);

  @override
  Future<Color> color(BuildContext context) {
    final colors = context.read<AvesColorsData>();
    switch (mime) {
      case MimeTypes.anyImage:
        return SynchronousFuture(colors.image);
      case MimeTypes.anyVideo:
        return SynchronousFuture(colors.video);
      default:
        return SynchronousFuture(colors.fromString(_label));
    }
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$mime';
}
