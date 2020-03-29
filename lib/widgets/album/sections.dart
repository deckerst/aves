import 'package:aves/utils/constants.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/fx/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySectionHeader extends StatelessWidget {
  final String text;

  DaySectionHeader({Key key, DateTime date})
      : text = _formatDate(date),
        super(key: key);

  static DateFormat md = DateFormat.MMMMd();
  static DateFormat ymd = DateFormat.yMMMMd();

  static String _formatDate(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    if (date.isThisYear) return md.format(date);
    return ymd.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return TitleSectionHeader(title: text);
  }
}

class MonthSectionHeader extends StatelessWidget {
  final String text;

  MonthSectionHeader({Key key, DateTime date})
      : text = _formatDate(date),
        super(key: key);

  static DateFormat m = DateFormat.MMMM();
  static DateFormat ym = DateFormat.yMMMM();

  static String _formatDate(DateTime date) {
    if (date.isThisMonth) return 'This month';
    if (date.isThisYear) return m.format(date);
    return ym.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return TitleSectionHeader(title: text);
  }
}

class TitleSectionHeader extends StatelessWidget {
  final Widget leading;
  final String title;

  const TitleSectionHeader({Key key, this.leading, this.title}) : super(key: key);

  static const leadingDimension = 32.0;
  static const leadingPadding = EdgeInsets.only(right: 8, bottom: 4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedText(
        leadingBuilder: leading != null
            ? (context, isShadow) => Container(
                  padding: leadingPadding,
                  width: leadingDimension,
                  height: leadingDimension,
                  child: isShadow ? null : leading,
                )
            : null,
        text: title,
        style: Constants.titleTextStyle,
        outlineWidth: 2,
      ),
    );
  }
}
