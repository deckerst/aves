import 'package:aves/locale/calendar/delegate/base.dart';
import 'package:flutter_hijri_rrule/flutter_hijri_rrule.dart';
import 'package:material_ui/material_ui.dart';

// placeholder to use as `DateTime` in the picker
class HijriDateTime(
  final IslamicCalendarType calendarType,
  super.year, [
  super.month = 1,
  super.day = 1,
]) extends DateTime {
  final int jMonth = month;
  final int jDay = day;

  factory now(IslamicCalendarType calendarType) {
    final j = HijriDate.now();
    return HijriDateTime(calendarType, j.year, j.month, j.day);
  }

  factory fromGregorian(IslamicCalendarType calendarType, DateTime gregorian) {
    final j = HijriDate.fromGregorian(gregorian, calendarType);
    return HijriDateTime(calendarType, j.year, j.month, j.day);
  }

  DateTime toGregorian() {
    return HijriDate(year, month, day).toGregorian(calendarType);
  }

  // necessary to set/get days like 31st of 4th month,
  // which `DateTime` overflows by default to 1st of 5th month
  @override
  int get month => jMonth;

  // necessary to set/get days like 31st of 4th month,
  // which `DateTime` overflows by default to 1st of 5th month
  @override
  int get day => jDay;
}

class const HijriCalendarDelegate(super.locale, final IslamicCalendarType calendarType) extends AvesCalendarDelegate<HijriDateTime> {
  static const int daysPerWeek = DateTime.daysPerWeek;
  static const int monthsPerYear = DateTime.monthsPerYear;

  @override
  DateTime toDateForIntl4xFormat(HijriDateTime date) {
    return date.toGregorian();
  }

  @override
  HijriDateTime now() => HijriDateTime.now(calendarType);

  @override
  HijriDateTime dateOnly(HijriDateTime date) {
    return HijriDateTime(calendarType, date.year, date.month, date.day);
  }

  @override
  int monthDelta(HijriDateTime startDate, HijriDateTime endDate) {
    return (endDate.year - startDate.year) * monthsPerYear + endDate.month - startDate.month;
  }

  @override
  HijriDateTime addMonthsToMonthDate(HijriDateTime monthDate, int monthsToAdd) {
    final int totalMonths = monthDate.year * monthsPerYear + monthDate.month - 1 + monthsToAdd;
    final int newYear = totalMonths ~/ monthsPerYear;
    final int newMonth = (totalMonths % monthsPerYear) + 1;
    return HijriDateTime(calendarType, newYear, newMonth, 1);
  }

  @override
  HijriDateTime addDaysToDate(HijriDateTime date, int days) {
    final g = date.toGregorian();
    final adjusted = DateTime(g.year, g.month, g.day + days);
    return HijriDateTime.fromGregorian(calendarType, adjusted);
  }

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    final g = HijriDate(year, month, 1).toGregorian(calendarType);
    final weekdayFromMonday = g.weekday - 1;
    final firstDayOfWeekIndex = (localizations.firstDayOfWeekIndex - 1) % daysPerWeek;
    return (weekdayFromMonday - firstDayOfWeekIndex) % daysPerWeek;
  }

  @override
  int getDaysInMonth(int year, int month) {
    return getMonthLength(year, month, calendarType);
  }

  @override
  HijriDateTime getMonth(int year, int month) {
    return HijriDateTime(calendarType, year, month, 1);
  }

  @override
  HijriDateTime getDay(int year, int month, int day) {
    return HijriDateTime(calendarType, year, month, day);
  }

  @override
  HijriDateTime? parseCompactDate(String? inputString, MaterialLocalizations localizations) {
    final parsed = localizations.parseCompactDate(inputString);
    if (parsed == null) return null;
    return HijriDateTime(calendarType, parsed.year, parsed.month, parsed.day);
  }
}
