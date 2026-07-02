// ignore_for_file: non_constant_identifier_names
import 'package:aves/utils/calendar/delegate/persian.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl4x/datetime_format.dart' as intl4x;

typedef DateFormatter = String Function(DateTime date);

/*
  * `intl` formatter examples (en_US)

  `MMMMd`:       `April 15`
  `yMMMMd`:      `April 15, 2020`
  `MMMEd`:       `Wed, Apr 15`
  `yMMMEd`:      `Wed, Apr 15, 2020`
  `MMMMEEEEd`:   `Wednesday, April 15`
  `yMMMMEEEEd`:  `Wednesday, April 15, 2020`
  `MEd`:         `Wed, 4/15`
  `yMEd`:        `Wed, 4/15/2020`

  * `intl` formatter examples (ko)

  `MMMMd`:       `1월 26일`
  `yMMMMd`:      `2021년 1월 26일`
  `MMMEd`:       `1월 26일 (화)`
  `yMMMEd`:      `2021년 1월 26일 (화)`
  `MMMMEEEEd`:   `1월 26일 화요일`
  `yMMMMEEEEd`:  `2021년 1월 26일 화요일`
  `MEd`:         `1. 26. (화)`
  `yMEd`:        `2021. 1. 26. (화)`

  * `intl4x` formatter examples (en-US locale, Gregorian calendar)

  year / short:   14
  year / medium:  2014
  year / long:    2014

  month / short:  3
  month / medium: Mar
  month / long:   March

  day / short:    1
  day / medium:   1
  day / long:     1

  monthDay / short:       3/1
  monthDay / medium:      Mar 1
  monthDay / long:        March 1

  yearMonthDay / short:   3/1/14
  yearMonthDay / medium:  Mar 1, 2014
  yearMonthDay / long:    March 1, 2014
 */
class AvesLocale {
  final String languageTag;
  final intl4x.Calendar calendar;
  final bool forceWesternArabicNumerals;
  late final intl4x.Locale _locale4x;

  AvesLocale({
    required this.languageTag,
    required this.calendar,
    required this.forceWesternArabicNumerals,
  }) {
    var locale = intl4x.Locale.parse(languageTag).withCalendar(calendar);
    if (forceWesternArabicNumerals) {
      locale = locale.withNumberingSystem(intl4x.NumberingSystem.latin);
    }
    _locale4x = locale;
  }

  AvesLocale copyWith({
    intl4x.Calendar? calendar,
  }) {
    return AvesLocale(
      languageTag: languageTag,
      calendar: calendar ?? this.calendar,
      forceWesternArabicNumerals: forceWesternArabicNumerals,
    );
  }

  // only use with `showDatePicker` / `DatePickerDialog`,
  // as delegates may rely on custom `DateTime` subclasses
  CalendarDelegate getDatePickerDelegate() {
    switch (calendar) {
      case .gregorian:
        return const GregorianCalendarDelegate();
      case .persian:
        return PersianCalendarDelegate(this);
      default:
        throw UnimplementedError();
    }
  }

  DateFormatter? _y;

  DateFormatter get y {
    _y ??= intl4x.DateTimeFormat.year(
      locale: _locale4x,
      length: intl4x.DateTimeLength.medium,
    ).format;
    return _y!;
  }

  DateFormatter? _MMM;

  DateFormatter get MMM {
    _MMM ??= intl4x.DateTimeFormat.month(
      locale: _locale4x,
      length: intl4x.DateTimeLength.medium,
    ).format;
    return _MMM!;
  }

  DateFormatter? _MMMM;

  DateFormatter get MMMM {
    _MMMM ??= intl4x.DateTimeFormat.month(
      locale: _locale4x,
      length: intl4x.DateTimeLength.long,
    ).format;
    return _MMMM!;
  }

  DateFormatter? _d;

  DateFormatter get d {
    _d ??= intl4x.DateTimeFormat.day(
      locale: _locale4x,
      length: intl4x.DateTimeLength.medium,
    ).format;
    return _d!;
  }

  DateFormatter? _MMMd;

  DateFormatter get MMMd {
    _MMMd ??= intl4x.DateTimeFormat.monthDay(
      locale: _locale4x,
      length: intl4x.DateTimeLength.medium,
    ).format;
    return _MMMd!;
  }

  DateFormatter? _MMMMd;

  DateFormatter get MMMMd {
    _MMMMd ??= intl4x.DateTimeFormat.monthDay(
      locale: _locale4x,
      length: intl4x.DateTimeLength.long,
    ).format;
    return _MMMMd!;
  }

  DateFormatter? _yMMM;

  DateFormatter get yMMM {
    if (_yMMM == null) {
      switch (calendar) {
        case .gregorian:
          _yMMM = intl.DateFormat.yMMM().format;
        default:
          // ideally, we would use an equivalent to intl `DateFormat.yMMM`,
          // but as of intl4x v0.17.0, there is no `DateTimeFormat.yearMonth`
          final y = intl4x.DateTimeFormat.year(
            locale: _locale4x,
            length: intl4x.DateTimeLength.medium,
          );
          final d = intl4x.DateTimeFormat.month(
            locale: _locale4x,
            length: intl4x.DateTimeLength.medium,
          );
          _yMMM = (v) => '${y.format(v)} ${d.format(v)}';
      }
    }
    return _yMMM!;
  }

  DateFormatter? _yMMMM;

  DateFormatter get yMMMM {
    if (_yMMMM == null) {
      switch (calendar) {
        case .gregorian:
          _yMMMM = intl.DateFormat.yMMMM(languageTag).format;
        default:
          // ideally, we would use an equivalent to intl `DateFormat.yMMMM`,
          // but as of intl4x v0.17.0, there is no `DateTimeFormat.yearMonth`
          final y = intl4x.DateTimeFormat.year(
            locale: _locale4x,
            length: intl4x.DateTimeLength.long,
          );
          final d = intl4x.DateTimeFormat.month(
            locale: _locale4x,
            length: intl4x.DateTimeLength.long,
          );
          _yMMMM = (v) => '${y.format(v)} ${d.format(v)}';
      }
    }
    return _yMMMM!;
  }

  DateFormatter? _MMMEd;

  DateFormatter get MMMEd {
    if (_MMMEd == null) {
      switch (calendar) {
        case .gregorian:
          _MMMEd = intl.DateFormat.MMMEd(languageTag).format;
        default:
          // ideally, we would use an equivalent to intl `DateFormat.MMMEd`,
          // but as of intl4x v0.17.0, there is no `DateTimeFormat.monthDayWeekday`
          final ymdw = intl4x.DateTimeFormat.yearMonthDayWeekday(
            locale: _locale4x,
            length: intl4x.DateTimeLength.medium,
          );
          _MMMEd = ymdw.format;
      }
    }
    return _MMMEd!;
  }

  DateFormatter? _yMd;

  DateFormatter get yMd {
    _yMd ??= intl4x.DateTimeFormat.yearMonthDay(
      locale: _locale4x,
      length: intl4x.DateTimeLength.short,
    ).format;
    return _yMd!;
  }

  DateFormatter? _yMMMd;

  DateFormatter get yMMMd {
    _yMMMd ??= intl4x.DateTimeFormat.yearMonthDay(
      locale: _locale4x,
      length: intl4x.DateTimeLength.medium,
    ).format;
    return _yMMMd!;
  }

  DateFormatter? _yMMMMd;

  DateFormatter get yMMMMd {
    _yMMMMd ??= intl4x.DateTimeFormat.yearMonthDay(
      locale: _locale4x,
      length: intl4x.DateTimeLength.long,
    ).format;
    return _yMMMMd!;
  }

  DateFormatter? _yMMMMEEEEd;

  DateFormatter get yMMMMEEEEd {
    _yMMMMEEEEd ??= intl4x.DateTimeFormat.yearMonthDayWeekday(
      locale: _locale4x,
      length: intl4x.DateTimeLength.long,
    ).format;
    return _yMMMMEEEEd!;
  }

  DateFormatter? _Hm;

  DateFormatter get Hm {
    _Hm ??= intl4x.DateTimeFormat.time(
      locale: _locale4x.withClockStyle(intl4x.ClockStyle.zeroToTwentyThree),
      length: intl4x.DateTimeLength.medium,
      timePrecision: intl4x.TimePrecision.minute,
    ).format;
    return _Hm!;
  }

  DateFormatter? _jm;

  DateFormatter get jm {
    _jm ??= intl4x.DateTimeFormat.time(
      locale: _locale4x.withClockStyle(intl4x.ClockStyle.zeroToEleven),
      length: intl4x.DateTimeLength.medium,
      timePrecision: intl4x.TimePrecision.minute,
    ).format;
    return _jm!;
  }
}
