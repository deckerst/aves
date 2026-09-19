// ignore_for_file: non_constant_identifier_names
import 'package:aves/locale/aves_locale.dart';
import 'package:aves/locale/calendar/dateformat/base.dart';
import 'package:aves/locale/intl4x.dart';
import 'package:intl4x/datetime_format.dart';

class Intl4xDateFormatDelegate({
  required super.languageTag,
  required ACalendar calendar,
  required bool forceWesternArabicNumerals,
}) extends DateFormatDelegate {
  final Locale _locale4x = Intl4x.toLocale4x(languageTag, calendar, forceWesternArabicNumerals);

  @override
  DateFormatter get y => DateTimeFormat.year(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get MMM => DateTimeFormat.month(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get MMMM => DateTimeFormat.month(locale: _locale4x, length: .long).format;

  @override
  DateFormatter get d => DateTimeFormat.day(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get MMMd => DateTimeFormat.monthDay(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get MMMMd => DateTimeFormat.monthDay(locale: _locale4x, length: .long).format;

  @override
  DateFormatter get yMMM => DateTimeFormat.yearMonth(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get yMMMM => DateTimeFormat.yearMonth(locale: _locale4x, length: .long).format;

  @override
  DateFormatter get MMMEd => DateTimeFormat.monthDayWeekday(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get yMd => DateTimeFormat.yearMonthDay(locale: _locale4x, length: .short).format;

  @override
  DateFormatter get yMMMd => DateTimeFormat.yearMonthDay(locale: _locale4x, length: .medium).format;

  @override
  DateFormatter get yMMMMd => DateTimeFormat.yearMonthDay(locale: _locale4x, length: .long).format;

  @override
  DateFormatter get yMMMMEEEEd => DateTimeFormat.yearMonthDayWeekday(locale: _locale4x, length: .long).format;

  @override
  DateFormatter get Hm => DateTimeFormat.time(locale: _locale4x.withClockStyle(.zeroToTwentyThree), length: .medium, timePrecision: .minute).format;

  @override
  DateFormatter get jm => DateTimeFormat.time(locale: _locale4x.withClockStyle(.zeroToEleven), length: .medium, timePrecision: .minute).format;
}
