import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/map/info_row.dart';
import 'package:flutter/material.dart';

class MapDateRow extends StatelessWidget {
  final AvesEntry? entry;

  const MapDateRow({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    final date = entry?.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : AText.valueNotAvailable;
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MapInfoRow.iconPadding),
              child: Icon(AIcons.date, size: MapInfoRow.getIconSize(context)),
            ),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(text: dateText),
        ],
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
    );
  }
}
