import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:collection/collection.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class OverlayRatingTagsRow extends AnimatedWidget {
  final AvesEntry entry;

  OverlayRatingTagsRow({
    super.key,
    required this.entry,
  }) : super(listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final String ratingString;
    final rating = entry.rating.clamp(-1, 5);
    switch (rating) {
      case -1:
        ratingString = context.l10n.filterRatingRejectedLabel;
      case 0:
        ratingString = '';
      default:
        ratingString = '${'★' * rating}${'☆' * (5 - rating)}';
    }

    final textScaler = MediaQuery.textScalerOf(context);
    final tags = entry.tags.toList()..sort(compareAsciiUpperCaseNatural);
    final hasTags = tags.isNotEmpty;

    const iconSize = ViewerDetailOverlayContent.iconSize;
    final textScaleFactor = textScaler.scale(iconSize) / iconSize;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: ratingString),
          if (hasTags) ...[
            if (ratingString.isNotEmpty) const TextSpan(text: AText.separator),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: ViewerDetailOverlayContent.iconPadding),
                child: DecoratedIcon(
                  AIcons.tag,
                  size: iconSize / textScaleFactor,
                  shadows: ViewerDetailOverlayContent.shadows(context),
                ),
              ),
            ),
            TextSpan(text: tags.join(AText.separator)),
          ]
        ],
      ),
      strutStyle: AStyles.overflowStrut,
    );
  }
}
