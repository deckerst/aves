import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/basic/text/icon_span.dart';
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
          IconSpan(
            icon: AIcons.date,
            size: MapInfoRow.getIconSize(context),
            padding: const EdgeInsets.symmetric(horizontal: MapInfoRow.iconPadding),
          ),
          TextSpan(text: dateText),
        ],
      ),
      softWrap: false,
      overflow: .fade,
      maxLines: 1,
    );
  }
}
