import 'package:aves/utils/calendar/ops/base.dart';

class GregorianCalendarOps extends CalendarOps {
  static final instance = GregorianCalendarOps._private();

  GregorianCalendarOps._private();

  @override
  DateTime asNative(DateTime date) => date;

  @override
  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  DateTime monthDateOnly(DateTime date) {
    return DateTime(date.year, date.month);
  }

  @override
  DateTime yearDateOnly(DateTime date) {
    return DateTime(date.year);
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) {
    return DateTime(date.year, date.month, date.day + days);
  }

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int months) {
    return DateTime(monthDate.year, monthDate.month + months);
  }

  @override
  DateTime addYearsToYearDate(DateTime yearDate, int years) {
    return DateTime(yearDate.year + years);
  }

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year;
  }

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
  }

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year && dateA?.month == dateB?.month && dateA?.day == dateB?.day;
  }

  @override
  bool isOnMonthDay(DateTime? date, int month, int day) {
    return date?.month == month && date?.day == day;
  }

  @override
  bool isOnMonth(DateTime? date, int month) {
    return date?.month == month;
  }

  @override
  bool isOnDay(DateTime? date, int day) {
    return date?.day == day;
  }

  @override
  (int year, int month) getYearMonth(DateTime date) {
    return (date.year, date.month);
  }

  @override
  (int year, int month, int day) getYearMonthDay(DateTime date) {
    return (date.year, date.month, date.day);
  }

  @override
  DateTime fromYearMonthDay(int? year, int? month, int? day) {
    return DateTime(year ?? 1, month ?? 1, day ?? 1);
  }
}
