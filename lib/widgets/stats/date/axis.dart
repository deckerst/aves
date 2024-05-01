import 'dart:math';

import 'package:aves/model/filters/date.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

// cf charts.DateTimeTickFormatter factory internals for default formats
class TimeAxisSpec {
  final List<charts.TickSpec<DateTime>> tickSpecs;

  TimeAxisSpec(this.tickSpecs);

  factory TimeAxisSpec.forLevel({
    required String locale,
    required DateLevel level,
    required DateTime first,
    required DateTime last,
  }) {
    switch (level) {
      case DateLevel.ymd:
        return TimeAxisSpec.days(locale, first, last);
      case DateLevel.ym:
        return TimeAxisSpec.months(locale, first, last);
      case DateLevel.y:
      default:
        return TimeAxisSpec.years(locale, first, last);
    }
  }

  factory TimeAxisSpec.days(String locale, DateTime first, DateTime last) {
    final daysTickLongFormat = DateFormat.MMMd(locale);
    final daysTickShortFormat = DateFormat.d(locale);

    first = first.date;
    last = last.date;
    final rangeDays = last.difference(first).inHumanDays;
    final delta = max(1, (rangeDays / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    int lastContext = -1;
    DateFormat dateFormat;
    for (int i = 0; i < rangeDays; i += delta) {
      final tickDate = first.addDays(i);
      if (lastContext != tickDate.month) {
        lastContext = tickDate.month;
        dateFormat = daysTickLongFormat;
      } else {
        dateFormat = daysTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat.format(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory TimeAxisSpec.months(String locale, DateTime first, DateTime last) {
    final monthsTickLongFormat = DateFormat.yMMM(locale);
    final monthsTickShortFormat = DateFormat.MMM(locale);

    first = DateTime(first.year, first.month);
    last = DateTime(last.year, last.month);
    final rangeMonths = last.month - first.month + (last.month < first.month ? 12 : 0);
    if (rangeMonths < 12) {
      first = first.addMonths(-((12 - rangeMonths) / 2).floor());
    }

    List<charts.TickSpec<DateTime>> ticks = [];
    int lastContext = -1;
    DateFormat dateFormat;
    for (int i = 0; i < DateTime.monthsPerYear; i += 3) {
      final tickDate = first.addMonths(2 + i);
      if (lastContext != tickDate.year) {
        lastContext = tickDate.year;
        dateFormat = monthsTickLongFormat;
      } else {
        dateFormat = monthsTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat.format(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory TimeAxisSpec.years(String locale, DateTime first, DateTime last) {
    final dateFormat = DateFormat.y(locale);

    final firstYear = first.year;
    final lastYear = last.year;
    final delta = max(1, ((lastYear - firstYear) / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    for (int year = firstYear; year <= lastYear; year += delta) {
      final tickDate = DateTime(year);
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat.format(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }
}
