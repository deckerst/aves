import 'package:aves/locale/calendar/delegate/base.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shamsi_date/shamsi_date.dart';

// placeholder to use as `DateTime` in the picker
class PersianDateTime extends DateTime {
  final int jMonth;
  final int jDay;

  new(super.year, [super.month = 1, super.day = 1]) : jMonth = month, jDay = day;

  factory now() {
    final j = Jalali.now();
    return PersianDateTime(j.year, j.month, j.day);
  }

  factory fromGregorian(DateTime gregorian) {
    final j = Jalali.fromDateTime(gregorian);
    return PersianDateTime(j.year, j.month, j.day);
  }

  DateTime toGregorian() {
    return Jalali(year, month, day).toDateTime();
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

class PersianCalendarDelegate extends AvesCalendarDelegate<PersianDateTime> {
  static const int daysPerWeek = DateTime.daysPerWeek;
  static const int monthsPerYear = DateTime.monthsPerYear;

  const new(super.locale);

  @override
  DateTime toDateForIntl4xFormat(PersianDateTime date) {
    return date.toGregorian();
  }

  @override
  PersianDateTime now() => PersianDateTime.now();

  @override
  PersianDateTime dateOnly(PersianDateTime date) {
    return PersianDateTime(date.year, date.month, date.day);
  }

  @override
  int monthDelta(PersianDateTime startDate, PersianDateTime endDate) {
    return (endDate.year - startDate.year) * monthsPerYear + endDate.month - startDate.month;
  }

  @override
  PersianDateTime addMonthsToMonthDate(PersianDateTime monthDate, int monthsToAdd) {
    final int totalMonths = monthDate.year * monthsPerYear + monthDate.month - 1 + monthsToAdd;
    final int newYear = totalMonths ~/ monthsPerYear;
    final int newMonth = (totalMonths % monthsPerYear) + 1;
    return PersianDateTime(newYear, newMonth, 1);
  }

  @override
  PersianDateTime addDaysToDate(PersianDateTime date, int days) {
    final g = date.toGregorian();
    final adjusted = DateTime(g.year, g.month, g.day + days);
    return PersianDateTime.fromGregorian(adjusted);
  }

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    final g = Jalali(year, month, 1).toDateTime();
    final weekdayFromMonday = g.weekday - 1;
    final firstDayOfWeekIndex = (localizations.firstDayOfWeekIndex - 1) % daysPerWeek;
    return (weekdayFromMonday - firstDayOfWeekIndex) % daysPerWeek;
  }

  @override
  int getDaysInMonth(int year, int month) {
    return Jalali(year, month, 1).monthLength;
  }

  @override
  PersianDateTime getMonth(int year, int month) {
    return PersianDateTime(year, month, 1);
  }

  @override
  PersianDateTime getDay(int year, int month, int day) {
    return PersianDateTime(year, month, day);
  }

  @override
  PersianDateTime? parseCompactDate(String? inputString, MaterialLocalizations localizations) {
    final parsed = localizations.parseCompactDate(inputString);
    if (parsed == null) return null;
    return PersianDateTime(parsed.year, parsed.month, parsed.day);
  }
}
