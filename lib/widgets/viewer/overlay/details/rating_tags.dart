import 'package:aves/model/entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/text/animated_diff.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    final tags = entry.tags.join(Constants.separator);
    final hasTags = tags.isNotEmpty;

    final animationDuration = context.select<DurationsData, Duration>((v) => v.textDiffAnimation);
    return Row(
      children: [
        AnimatedDiffText(
          ratingString,
          strutStyle: Constants.overflowStrutStyle,
          duration: animationDuration,
        ),
        if (hasTags) ...[
          if (ratingString.isNotEmpty) const Text(Constants.separator),
          DecoratedIcon(AIcons.tag, size: ViewerDetailOverlayContent.iconSize, shadows: ViewerDetailOverlayContent.shadows(context)),
          const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
          Expanded(
            child: AnimatedDiffText(
              tags,
              strutStyle: Constants.overflowStrutStyle,
              duration: animationDuration,
            ),
          ),
        ],
      ],
    );
  }
}
