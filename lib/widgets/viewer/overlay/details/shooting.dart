import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverlayShootingRow extends StatelessWidget {
  final OverlayMetadata details;

  const OverlayShootingRow({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    final aperture = details.aperture;
    final apertureText = aperture != null ? 'ƒ/${NumberFormat('0.0', locale).format(aperture)}' : AText.valueNotAvailable;

    final focalLength = details.focalLength;
    final focalLengthText = focalLength != null ? context.l10n.focalLength(NumberFormat('0.#', locale).format(focalLength)) : AText.valueNotAvailable;

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
