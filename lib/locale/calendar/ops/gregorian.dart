import 'package:aves/locale/calendar/ops/base.dart';

class GregorianCalendarOps extends CalendarOps {
  @override
  int get monthsPerYear => DateTime.monthsPerYear;

  static final instance = GregorianCalendarOps._private();

  new _private();

  @override
  DateTime asNative(DateTime date) => date;

  @override
  DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  DateTime monthDateOnly(DateTime date) => DateTime(date.year, date.month);

  @override
  DateTime yearDateOnly(DateTime date) => DateTime(date.year);

  @override
  DateTime addDaysToDate(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int months) => DateTime(monthDate.year, monthDate.month + months);

  @override
  DateTime addYearsToYearDate(DateTime yearDate, int years) => DateTime(yearDate.year + years);

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) => dateA?.year == dateB?.year;

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) => dateA?.year == dateB?.year && dateA?.month == dateB?.month;

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) => dateA?.year == dateB?.year && dateA?.month == dateB?.month && dateA?.day == dateB?.day;

  @override
  bool isOnMonthDay(DateTime? date, int month, int day) => date?.month == month && date?.day == day;

  @override
  bool isOnMonth(DateTime? date, int month) => date?.month == month;

  @override
  bool isOnDay(DateTime? date, int day) => date?.day == day;

  @override
  int getYear(DateTime date) => date.year;

  @override
  (int year, int month) getYearMonth(DateTime date) => (date.year, date.month);

  @override
  (int year, int month, int day) getYearMonthDay(DateTime date) => (date.year, date.month, date.day);

  @override
  DateTime fromYearMonthDay(int? year, int? month, int? day) => DateTime(year ?? 1, month ?? 1, day ?? 1);

  @override
  int yearDelta(DateTime startDate, DateTime endDate) => endDate.year - startDate.year;

  @override
  int monthDelta(DateTime startDate, DateTime endDate) => (endDate.year - startDate.year) * monthsPerYear + endDate.month - startDate.month;
}
