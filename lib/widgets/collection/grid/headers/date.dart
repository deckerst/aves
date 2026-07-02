import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/utils/calendar/intl4x_format.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySectionHeader<T> extends StatelessWidget {
  final DateTime? date;
  final bool selectable;

  const DaySectionHeader({
    super.key,
    required this.date,
    required this.selectable,
  });

  static String _formatDate(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    if (date.isToday) return l10n.dateToday;
    if (date.isYesterday) return l10n.dateYesterday;

    final localeName = context.localeName;
    final locale = settings.intl4xLocale();
    final weekday = DateFormat.E(localeName).format(date);
    if (date.isThisYear) return '${locale.MMMMd()(date)} ($weekday)';
    return '${locale.yMMMMd()(date)} ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: EntryDateSectionKey(date),
      title: _formatDate(context, date),
      selectable: selectable,
    );
  }
}

class MonthSectionHeader<T> extends StatelessWidget {
  final DateTime? date;
  final bool selectable;

  const MonthSectionHeader({
    super.key,
    required this.date,
    required this.selectable,
  });

  static String _formatDate(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    if (date.isThisMonth) return l10n.dateThisMonth;

    final localeName = context.localeName;
    final locale = settings.intl4xLocale();
    final calendar = settings.calendar;
    final formatter = date.isThisYear ? locale.MMMM() : locale.yMMMM(localeName, calendar);
    final localized = formatter(date);
    return '${localized.substring(0, 1).toUpperCase()}${localized.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: EntryDateSectionKey(date),
      title: _formatDate(context, date),
      selectable: selectable,
    );
  }
}
