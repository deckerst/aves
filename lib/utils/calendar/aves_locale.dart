// ignore_for_file: non_constant_identifier_names
import 'package:aves/ref/locales.dart';
import 'package:aves/utils/calendar/dateformat/base.dart';
import 'package:aves/utils/calendar/dateformat/intl.dart';
import 'package:aves/utils/calendar/dateformat/intl4x.dart';
import 'package:aves/utils/calendar/delegate/persian.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

typedef ACalendar = intl4x.Calendar;

class AvesLocale {
  final String languageTag;
  final ACalendar calendar;
  final bool forceWesternArabicNumerals;
  late final DateFormatDelegate _dateFormatDelegate;

  AvesLocale({
    required this.languageTag,
    required this.calendar,
    required this.forceWesternArabicNumerals,
  }) {
    _dateFormatDelegate = _getDateFormatDelegate();
  }

  static final AvesLocale ascii = AvesLocale(
    languageTag: kAsciiLocale,
    calendar: ACalendar.gregorian,
    forceWesternArabicNumerals: false,
  );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{languageTag=$languageTag, calendar=$calendar, forceWesternArabicNumerals=$forceWesternArabicNumerals}';

  AvesLocale copyWith({
    ACalendar? calendar,
  }) {
    return AvesLocale(
      languageTag: languageTag,
      calendar: calendar ?? this.calendar,
      forceWesternArabicNumerals: forceWesternArabicNumerals,
    );
  }

  NumberFormat numberFormat(String pattern) {
    return NumberFormat(pattern, languageTag);
  }

  NumberFormat decimalNumberFormat() {
    return NumberFormat.decimalPattern(languageTag);
  }

  NumberFormat percentNumberFormat() {
    return NumberFormat.percentPattern(languageTag);
  }

  // only use with `showDatePicker` / `DatePickerDialog`,
  // as delegates may rely on custom `DateTime` subclasses
  CalendarDelegate getDatePickerDelegate() {
    switch (calendar) {
      case .persian:
        return PersianCalendarDelegate(this);
      default:
        return const GregorianCalendarDelegate();
    }
  }

  DateFormatDelegate _getDateFormatDelegate() {
    switch (calendar) {
      case .persian:
        return Intl4xDateFormatDelegate(
          languageTag: languageTag,
          calendar: calendar,
          forceWesternArabicNumerals: forceWesternArabicNumerals,
        );
      default:
        return IntlDateFormatDelegate(languageTag: languageTag);
    }
  }

  DateFormatter? _y;

  DateFormatter get y {
    _y ??= _dateFormatDelegate.y;
    return _y!;
  }

  DateFormatter? _MMM;

  DateFormatter get MMM {
    _MMM ??= _dateFormatDelegate.MMM;
    return _MMM!;
  }

  DateFormatter? _MMMM;

  DateFormatter get MMMM {
    _MMMM ??= _dateFormatDelegate.MMMM;
    return _MMMM!;
  }

  DateFormatter? _d;

  DateFormatter get d {
    _d ??= _dateFormatDelegate.d;
    return _d!;
  }

  DateFormatter? _MMMd;

  DateFormatter get MMMd {
    _MMMd ??= _dateFormatDelegate.MMMd;
    return _MMMd!;
  }

  DateFormatter? _MMMMd;

  DateFormatter get MMMMd {
    _MMMMd ??= _dateFormatDelegate.MMMMd;
    return _MMMMd!;
  }

  DateFormatter? _yMMM;

  DateFormatter get yMMM {
    _yMMM ??= _dateFormatDelegate.yMMM;
    return _yMMM!;
  }

  DateFormatter? _yMMMM;

  DateFormatter get yMMMM {
    _yMMMM ??= _dateFormatDelegate.yMMMM;
    return _yMMMM!;
  }

  DateFormatter? _MMMEd;

  DateFormatter get MMMEd {
    _MMMEd ??= _dateFormatDelegate.MMMEd;
    return _MMMEd!;
  }

  DateFormatter? _yMd;

  DateFormatter get yMd {
    _yMd ??= _dateFormatDelegate.yMd;
    return _yMd!;
  }

  DateFormatter? _yMMMd;

  DateFormatter get yMMMd {
    _yMMMd ??= _dateFormatDelegate.yMMMd;
    return _yMMMd!;
  }

  DateFormatter? _yMMMMd;

  DateFormatter get yMMMMd {
    _yMMMMd ??= _dateFormatDelegate.yMMMMd;
    return _yMMMMd!;
  }

  DateFormatter? _yMMMMEEEEd;

  DateFormatter get yMMMMEEEEd {
    _yMMMMEEEEd ??= _dateFormatDelegate.yMMMMEEEEd;
    return _yMMMMEEEEd!;
  }

  DateFormatter? _Hm;

  DateFormatter get Hm {
    _Hm ??= _dateFormatDelegate.Hm;
    return _Hm!;
  }

  DateFormatter? _jm;

  DateFormatter get jm {
    _jm ??= _dateFormatDelegate.jm;
    return _jm!;
  }
}
