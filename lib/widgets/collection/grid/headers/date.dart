import 'package:aves/model/source/section_keys.dart';
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

  // Examples (en_US):
  // `MMMMd`:       `April 15`
  // `yMMMMd`:      `April 15, 2020`
  // `MMMEd`:       `Wed, Apr 15`
  // `yMMMEd`:      `Wed, Apr 15, 2020`
  // `MMMMEEEEd`:   `Wednesday, April 15`
  // `yMMMMEEEEd`:  `Wednesday, April 15, 2020`
  // `MEd`:         `Wed, 4/15`
  // `yMEd`:        `Wed, 4/15/2020`

  // Examples (ko):
  // `MMMMd`:       `1월 26일`
  // `yMMMMd`:      `2021년 1월 26일`
  // `MMMEd`:       `1월 26일 (화)`
  // `yMMMEd`:      `2021년 1월 26일 (화)`
  // `MMMMEEEEd`:   `1월 26일 화요일`
  // `yMMMMEEEEd`:  `2021년 1월 26일 화요일`
  // `MEd`:         `1. 26. (화)`
  // `yMEd`:        `2021. 1. 26. (화)`

  static String _formatDate(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;
    if (date.isToday) return l10n.dateToday;
    if (date.isYesterday) return l10n.dateYesterday;

    final locale = context.locale;
    if (date.isThisYear) return '${DateFormat.MMMMd(locale).format(date)} (${DateFormat.E(locale).format(date)})';
    return '${DateFormat.yMMMMd(locale).format(date)} (${DateFormat.E(locale).format(date)})';
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

    final locale = context.locale;
    final localized = date.isThisYear ? DateFormat.MMMM(locale).format(date) : DateFormat.yMMMM(locale).format(date);
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
