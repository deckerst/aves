import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class OverlayDateRow extends StatelessWidget {
  final AvesEntry entry;
  final MultiPageController? multiPageController;

  const OverlayDateRow({
    super.key,
    required this.entry,
    required this.multiPageController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : AText.valueNotAvailable;
    final resolutionText = entry.isSvg
        ? entry.aspectRatioText
        : entry.isSized
            ? entry.getResolutionText(locale)
            : '';

    return Row(
      children: [
        DecoratedIcon(AIcons.date, size: ViewerDetailOverlayContent.iconSize, shadows: ViewerDetailOverlayContent.shadows(context)),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(flex: 3, child: Text(dateText)),
        Expanded(flex: 2, child: Text(resolutionText)),
      ],
    );
  }
}
