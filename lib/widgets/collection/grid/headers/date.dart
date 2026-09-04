import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class DaySectionHeader<T> extends StatelessWidget {
  final SectionKey sectionKey;
  final DateTime? date;
  final bool selectable;

  const new({
    super.key,
    required this.sectionKey,
    required this.date,
    required this.selectable,
  });

  static String _formatDate(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;

    final locale = settings.avesLocale;
    final calOps = locale.calendar.ops;

    if (calOps.isToday(date)) return l10n.dateToday;
    if (calOps.isYesterday(date)) return l10n.dateYesterday;

    final weekday = DateFormat.E(locale.languageTag).format(date);
    if (calOps.isThisYear(date)) return '${locale.MMMMd(date)} ($weekday)';
    return '${locale.yMMMMd(date)} ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: sectionKey,
      title: _formatDate(context, date),
      selectable: selectable,
    );
  }
}

class MonthSectionHeader<T> extends StatelessWidget {
  final SectionKey sectionKey;
  final DateTime? date;
  final bool selectable;

  const new({
    super.key,
    required this.sectionKey,
    required this.date,
    required this.selectable,
  });

  static String _formatDate(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.sectionUnknown;

    final locale = settings.avesLocale;
    final calOps = locale.calendar.ops;

    if (calOps.isThisMonth(date)) return l10n.dateThisMonth;

    final formatter = calOps.isThisYear(date) ? locale.MMMM : locale.yMMMM;
    final localized = formatter(date);
    return '${localized.substring(0, 1).toUpperCase()}${localized.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: sectionKey,
      title: _formatDate(context, date),
      selectable: selectable,
    );
  }
}
