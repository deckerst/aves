import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/top/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:material_ui/material_ui.dart';

class OverlayShootingRow extends StatelessWidget {
  final OverlayMetadata details;

  const new({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final locale = settings.avesLocale;

    final aperture = details.aperture;
    final apertureText = aperture != null ? 'ƒ/${locale.numberFormat('0.0').format(aperture)}' : AText.valueNotAvailable;

    final focalLength = details.focalLength;
    final focalLengthText = focalLength != null ? context.l10n.focalLength(locale.numberFormat('0.#').format(focalLength)) : AText.valueNotAvailable;

    final iso = details.iso;
    final isoText = iso != null ? 'ISO$iso' : AText.valueNotAvailable;

    return Row(
      children: [
        DecoratedIcon(AIcons.shooting, size: ViewerDetailOverlayContent.iconSize, shadows: ViewerDetailOverlayContent.shadows(context)),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(child: Text(apertureText)),
        Expanded(child: Text(details.exposureTime ?? AText.valueNotAvailable)),
        Expanded(child: Text(focalLengthText)),
        Expanded(child: Text(isoText)),
      ],
    );
  }
}
