import 'dart:math';

import 'package:aves/model/filters/date.dart';
import 'package:aves/utils/calendar/calendar_utils.dart';
import 'package:aves/utils/calendar/intl4x_format.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:intl4x/datetime_format.dart' as intl4x;

// cf charts.DateTimeTickFormatter factory internals for default formats
class TimeAxisSpec {
  final List<charts.TickSpec<DateTime>> tickSpecs;

  TimeAxisSpec(this.tickSpecs);

  factory TimeAxisSpec.forLevel({
    required intl4x.Locale locale,
    required intl4x.Calendar calendar,
    required DateLevel level,
    required DateTime first,
    required DateTime last,
  }) {
    switch (level) {
      case .ymd:
        return TimeAxisSpec.days(locale, first, last);
      case .ym:
        return TimeAxisSpec.months(locale, calendar, first, last);
      case .y:
      default:
        return TimeAxisSpec.years(locale, first, last);
    }
  }

  factory TimeAxisSpec.days(intl4x.Locale locale, DateTime first, DateTime last) {
    final daysTickLongFormat = locale.MMMd();
    final daysTickShortFormat = locale.d();

    first = first.date;
    last = last.date;
    final rangeDays = last.difference(first).inHumanDays;
    final delta = max(1, (rangeDays / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    int lastContext = -1;
    DateFormatter dateFormat;
    for (int i = 0; i < rangeDays; i += delta) {
      final tickDate = first.addDays(i);
      if (lastContext != tickDate.month) {
        lastContext = tickDate.month;
        dateFormat = daysTickLongFormat;
      } else {
        dateFormat = daysTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory TimeAxisSpec.months(intl4x.Locale locale, intl4x.Calendar calendar, DateTime first, DateTime last) {
    final monthsTickLongFormat = locale.yMMM(locale.toLanguageTag(), calendar);
    final monthsTickShortFormat = locale.MMM();

    first = DateTime(first.year, first.month);
    last = DateTime(last.year, last.month);
    final monthsInYear = calendar.maxMonthsInYear;
    final rangeMonths = last.month - first.month + (last.month < first.month ? monthsInYear : 0);
    if (rangeMonths < monthsInYear) {
      first = first.addMonths(-((monthsInYear - rangeMonths) / 2).floor());
    }

    List<charts.TickSpec<DateTime>> ticks = [];
    int lastContext = -1;
    DateFormatter dateFormat;
    for (int i = 0; i < DateTime.monthsPerYear; i += 3) {
      final tickDate = first.addMonths(2 + i);
      if (lastContext != tickDate.year) {
        lastContext = tickDate.year;
        dateFormat = monthsTickLongFormat;
      } else {
        dateFormat = monthsTickShortFormat;
      }
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }

  factory TimeAxisSpec.years(intl4x.Locale locale, DateTime first, DateTime last) {
    final dateFormat = locale.y();

    final firstYear = first.year;
    final lastYear = last.year;
    final delta = max(1, ((lastYear - firstYear) / 5).ceil());

    List<charts.TickSpec<DateTime>> ticks = [];
    for (int year = firstYear; year <= lastYear; year += delta) {
      final tickDate = DateTime(year);
      ticks.add(charts.TickSpec<DateTime>(tickDate, label: dateFormat(tickDate)));
    }
    return TimeAxisSpec(ticks);
  }
}
