import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class OverlayLocationRow extends AnimatedWidget {
  final AvesEntry entry;

  OverlayLocationRow({
    super.key,
    required this.entry,
  }) : super(listenable: entry.addressChangeNotifier);

  @override
  Widget build(BuildContext context) {
    String? location;
    if (entry.hasAddress) {
      location = entry.shortAddress;
    }
    if (location == null || location.isEmpty) {
      final latLng = entry.latLng;
      if (latLng != null) {
        location = settings.coordinateFormat.format(context.l10n, latLng);
      }
    }
    return Row(
      children: [
        DecoratedIcon(AIcons.location, size: ViewerDetailOverlayContent.iconSize, shadows: ViewerDetailOverlayContent.shadows(context)),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(child: Text(location ?? AText.valueNotAvailable, strutStyle: AStyles.overflowStrut)),
      ],
    );
  }
}
