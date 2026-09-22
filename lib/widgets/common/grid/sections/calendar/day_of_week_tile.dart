import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/grid/sections/calendar/day_tile.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class const DayOfWeekTile({
  super.key,
  required final int day,
}) extends StatelessWidget {
  static const _padding = EdgeInsets.all(4);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: .center,
      color: Themes.secondLayerColor(context),
      foregroundDecoration: DayTile.tileDecoration(context),
      child: Text(_narrowWeekdays(context)[day]),
    );
  }

  static double computeLineHeight(BuildContext context) {
    final paragraph = RenderParagraph(
      TextSpan(
        children: _narrowWeekdays(context).map((v) => TextSpan(text: v)).toList(),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final textHeight = paragraph.getMaxIntrinsicHeight(double.infinity);
    paragraph.dispose();
    return textHeight + _padding.vertical;
  }

  static List<String> _narrowWeekdays(BuildContext context) => MaterialLocalizations.of(context).narrowWeekdays;
}
