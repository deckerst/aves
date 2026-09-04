import 'dart:math';

import 'package:aves/locale/aves_locale.dart';
import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/locale/calendar/dateformat/base.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

// cf charts.DateTimeTickFormatter factory internals for default formats
class TimeAxisSpec {
  final List<charts.TickSpec<DateTime>> tickSpecs;

  new(this.tickSpecs);

  factory forLevel({
    required AvesLocale locale,
    required DateLevel level,
    required DateTime first,
    required DateTime last,
  }) {
    switch (level) {
      case .ymd:
        return TimeAxisSpec.days(locale, first, last);
      case .ym:
        return TimeAxisSpec.months(locale, first, last);
      case .y:
      default:
        return TimeAxisSpec.years(locale, first, last);
    }
  }

  factory days(AvesLocale locale, DateTime first, DateTime last) {
    final daysTickLongFormat = locale.MMMd;
    final daysTickShortFormat = locale.d;
    final calOps = locale.calendar.ops;

    first = calOps.dateOnly(first);
    last = calOps.dateOnly(last);
    final rangeDays = last.difference(first).inHumanDays;
    final delta = max(1, (rangeDays / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    (int, int) lastContext = (-1, -1);
    DateFormatter dateFormat;
    for (int i = 0; i < rangeDays; i += delta) {
      final tickDate = calOps.addDaysToDate(first, i);
      final tickContext = calOps.getYearMonth(tickDate);
      if (lastContext != tickContext) {
        lastContext = tickContext;
        dateFormat = daysTickLongFormat;
      } else {
        dateFormat = daysTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory months(AvesLocale locale, DateTime first, DateTime last) {
    final monthsTickLongFormat = locale.yMMM;
    final monthsTickShortFormat = locale.MMM;
    final calOps = locale.calendar.ops;

    first = calOps.monthDateOnly(first);
    last = calOps.monthDateOnly(last);
    final monthsPerYear = calOps.monthsPerYear;
    final rangeMonths = calOps.monthDelta(first, last);
    if (rangeMonths < monthsPerYear) {
      // push back first date in the past, so that data will land in the middle of chart
      first = calOps.addMonthsToMonthDate(first, -((monthsPerYear - rangeMonths) / 2).floor());
    }

    List<charts.TickSpec<DateTime>> ticks = [];
    int lastContext = -1;
    DateFormatter dateFormat;
    for (int i = 0; i < calOps.monthsPerYear; i += 3) {
      final tickDate = calOps.addMonthsToMonthDate(first, 2 + i);
      final tickContext = calOps.getYear(tickDate);
      if (lastContext != tickContext) {
        lastContext = tickContext;
        dateFormat = monthsTickLongFormat;
      } else {
        dateFormat = monthsTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory years(AvesLocale locale, DateTime first, DateTime last) {
    final dateFormat = locale.y;
    final calOps = locale.calendar.ops;

    final firstYear = calOps.getYear(first);
    final lastYear = calOps.getYear(last);
    final rangeYears = lastYear - firstYear;
    final delta = max(1, (rangeYears / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    for (int i = 0; i < rangeYears; i += delta) {
      final tickDate = calOps.addYearsToYearDate(first, i);
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }
}
