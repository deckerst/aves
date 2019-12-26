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
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isThisYear(date)) return md.format(date);
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
    if (isThisMonth(date)) return 'This month';
    if (isThisYear(date)) return m.format(date);
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

  @override
  Widget build(BuildContext context) {
    final text = OutlinedText(
      title,
      style: TextStyle(
        color: Colors.grey[200],
        fontSize: 20,
        fontFamily: 'Concourse Caps',
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 3,
            color: Colors.grey[900],
          ),
        ],
      ),
      outlineColor: Colors.black87,
      outlineWidth: 2,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      child: leading != null
          ? Row(
              children: [
                leading,
                const SizedBox(width: 8),
                text,
              ],
            )
          : text,
    );
  }
}
