import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/top/details/details.dart';
import 'package:material_ui/material_ui.dart';

class const OverlayDateRow({
  super.key,
  required final AvesEntry entry,
  required final MultiPageController? multiPageController,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = settings.avesLocale;
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
        Icon(
          AIcons.date,
          size: ViewerDetailOverlayContent.iconSize,
          shadows: ViewerDetailOverlayContent.shadows(context),
        ),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(flex: 3, child: Text(dateText)),
        Expanded(flex: 2, child: Text(resolutionText)),
      ],
    );
  }
}
