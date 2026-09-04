import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/map/info_row.dart';
import 'package:material_ui/material_ui.dart';

class MapDateRow extends StatelessWidget {
  final AvesEntry? entry;

  const new({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    final date = entry?.bestDate;
    final dateText = date != null ? formatDateTime(date, settings.avesLocale, use24hour) : AText.valueNotAvailable;
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
