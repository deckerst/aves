import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
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
        break;
      case 0:
        ratingString = '';
        break;
      default:
        ratingString = '${'★' * rating}${'☆' * (5 - rating)}';
        break;
    }

    final tags = entry.tags.toList()..sort(compareAsciiUpperCaseNatural);
    final hasTags = tags.isNotEmpty;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: ratingString),
          if (hasTags) ...[
            if (ratingString.isNotEmpty) const TextSpan(text: Constants.separator),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: ViewerDetailOverlayContent.iconPadding),
                child: DecoratedIcon(
                  AIcons.tag,
                  size: ViewerDetailOverlayContent.iconSize,
                  shadows: ViewerDetailOverlayContent.shadows(context),
                ),
              ),
            ),
            TextSpan(text: tags.join(Constants.separator)),
          ]
        ],
      ),
      strutStyle: Constants.overflowStrutStyle,
    );
  }
}
