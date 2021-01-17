import 'package:aves/model/source/section_keys.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySectionHeader extends StatelessWidget {
  final DateTime date;
  final String text;

  DaySectionHeader({
    Key key,
    @required this.date,
  })  : text = _formatDate(date),
        super(key: key);

  // Examples (en_US):
  // `MMMMd`: `April 15`
  // `yMMMMd`: `April 15, 2020`
  // `MMMEd`: `Wed, Apr 15`
  // `yMMMEd`: `Wed, Apr 15, 2020`
  // `MMMMEEEEd`: `Wednesday, April 15`
  // `yMMMMEEEEd`: `Wednesday, April 15, 2020`
  // `MEd`: `Wed, 4/15`
  // `yMEd`: `Wed, 4/15/2020`
  static DateFormat md = DateFormat.MMMMd();
  static DateFormat ymd = DateFormat.yMMMMd();
  static DateFormat day = DateFormat.E();

  static String _formatDate(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    if (date.isThisYear) return '${md.format(date)} (${day.format(date)})';
    return '${ymd.format(date)} (${day.format(date)})';
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      sectionKey: EntryDateSectionKey(date),
      title: text,
    );
  }
}

class MonthSectionHeader extends StatelessWidget {
  final DateTime date;
  final String text;

  MonthSectionHeader({
    Key key,
    @required this.date,
  })  : text = _formatDate(date),
        super(key: key);

  static DateFormat m = DateFormat.MMMM();
  static DateFormat ym = DateFormat.yMMMM();

  static String _formatDate(DateTime date) {
    if (date == null) return 'Unknown';
    if (date.isThisMonth) return 'This month';
    if (date.isThisYear) return m.format(date);
    return ym.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      sectionKey: EntryDateSectionKey(date),
      title: text,
    );
  }
}
