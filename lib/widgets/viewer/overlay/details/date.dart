import 'package:aves/model/entry.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : Constants.overlayUnknown;
    final resolutionText = entry.isSvg
        ? entry.aspectRatioText
        : entry.isSized
            ? entry.resolutionText
            : '';

    return Row(
      children: [
        DecoratedIcon(AIcons.date, size: ViewerDetailOverlayContent.iconSize, shadows: ViewerDetailOverlayContent.shadows(context)),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(flex: 3, child: Text(dateText, strutStyle: Constants.overflowStrutStyle)),
        Expanded(flex: 2, child: Text(resolutionText, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}
