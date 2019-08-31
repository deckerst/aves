import 'package:aves/utils/date_utils.dart';
import 'package:aves/widgets/common/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySectionHeader extends StatelessWidget {
  final String text;

  DaySectionHeader({Key key, DateTime date})
      : text = formatDate(date),
        super(key: key);

  static DateFormat md = DateFormat.MMMMd();
  static DateFormat ymd = DateFormat.yMMMMd();

  static formatDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isThisYear(date)) return md.format(date);
    return ymd.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(text: text);
  }
}

class MonthSectionHeader extends StatelessWidget {
  final String text;

  MonthSectionHeader({Key key, DateTime date})
      : text = formatDate(date),
        super(key: key);

  static DateFormat m = DateFormat.MMMM();
  static DateFormat ym = DateFormat.yMMMM();

  static formatDate(DateTime date) {
    if (isThisMonth(date)) return 'This month';
    if (isThisYear(date)) return m.format(date);
    return ym.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(text: text);
  }
}

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: OutlinedText(
        text,
        style: TextStyle(
          color: Colors.grey[200],
          fontSize: 20,
          fontFamily: 'Concourse Caps',
          shadows: [
            Shadow(
              offset: Offset(0, 2),
              blurRadius: 3,
              color: Colors.grey[900],
            ),
          ],
        ),
        outlineColor: Colors.black87,
        outlineWidth: 2,
      ),
    );
  }
}
