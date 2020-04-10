import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/album/grid/header_generic.dart';
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
