// ignore_for_file: non_constant_identifier_names
import 'package:aves/locale/calendar/dateformat/base.dart';
import 'package:aves/locale/calendar/dateformat/intl.dart';
import 'package:aves/locale/calendar/dateformat/intl4x.dart';
import 'package:aves/locale/calendar/delegate/persian.dart';
import 'package:aves/locale/intl4x.dart';
import 'package:aves/locale/number.dart';
import 'package:aves/ref/locales.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl4x/datetime_format.dart' as date4x;
import 'package:intl4x/number_format.dart' as num4x;

typedef ACalendar = date4x.Calendar;

class AvesLocale {
  final String languageTag;
  final ACalendar calendar;
  final bool forceWesternArabicNumerals;
  late final DateFormatDelegate _dateFormatDelegate;
  late final num4x.Locale _locale4x;

  new({
    required this.languageTag,
    required this.calendar,
    required this.forceWesternArabicNumerals,
  }) {
    _dateFormatDelegate = _getDateFormatDelegate();
    _locale4x = Intl4x.toLocale4x(languageTag, calendar, forceWesternArabicNumerals);
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

  ANumberFormat numberFormat(String pattern) {
    return ANumberFormat.fromIntl(intl.NumberFormat(pattern, languageTag));
  }

  ANumberFormat decimalNumberFormat() {
    return ANumberFormat.fromIntl4x(num4x.NumberFormat(locale: _locale4x));
  }

  ANumberFormat percentNumberFormat() {
    return ANumberFormat.fromIntl(intl.NumberFormat.percentPattern(languageTag));
    // as of intl4x v1.0.0-alpha.2 `NumberFormat.percent` is not implemented for native
    // return ANumberFormat.fromIntl4x(num4x.NumberFormat.percent(locale: _locale4x));
  }

  ANumberParser numberParser(String pattern) {
    return ANumberParser.fromIntl(intl.NumberFormat(pattern, languageTag));
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
