import 'package:aves/locale/calendar/ops/base.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PersianCalendarOps extends CalendarOps {
  @override
  int get monthsPerYear => DateTime.monthsPerYear;

  static final instance = PersianCalendarOps._private();

  new _private();

  Jalali? toNative(DateTime? date) => date?.toJalali();

  @override
  DateTime asNative(DateTime date) => Jalali(
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
  ).toDateTime();

  @override
  DateTime dateOnly(DateTime date) {
    final j = toNative(date)!.copy(hour: 0, minute: 0, second: 0, millisecond: 0);
    return j.toDateTime();
  }

  @override
  DateTime monthDateOnly(DateTime date) {
    final j = toNative(date)!.copy(day: 1, hour: 0, minute: 0, second: 0, millisecond: 0);
    return j.toDateTime();
  }

  @override
  DateTime yearDateOnly(DateTime date) {
    final j = toNative(date)!.copy(month: 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 0);
    return j.toDateTime();
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) {
    final j = toNative(date)!.addDays(days);
    return j.toDateTime();
  }

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int months) {
    final j = toNative(monthDate)!.addMonths(months);
    return j.toDateTime();
  }

  @override
  DateTime addYearsToYearDate(DateTime yearDate, int years) {
    final j = toNative(yearDate)!.addYears(years);
    return j.toDateTime();
  }

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) {
    final jA = toNative(dateA);
    final jB = toNative(dateB);
    return jA?.year == jB?.year;
  }

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) {
    final jA = toNative(dateA);
    final jB = toNative(dateB);
    return jA?.year == jB?.year && jA?.month == jB?.month;
  }

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) {
    final jA = toNative(dateA);
    final jB = toNative(dateB);
    return jA?.year == jB?.year && jA?.month == jB?.month && jA?.day == jB?.day;
  }

  @override
  bool isOnMonthDay(DateTime? date, int month, int day) {
    final jA = toNative(date);
    return jA?.month == month && jA?.day == day;
  }

  @override
  bool isOnMonth(DateTime? date, int month) {
    final jA = toNative(date);
    return jA?.month == month;
  }

  @override
  bool isOnDay(DateTime? date, int day) {
    final jA = toNative(date);
    return jA?.day == day;
  }

  @override
  int getYear(DateTime date) {
    final j = toNative(date)!;
    return j.year;
  }

  @override
  (int year, int month) getYearMonth(DateTime date) {
    final j = toNative(date)!;
    return (j.year, j.month);
  }

  @override
  (int year, int month, int day) getYearMonthDay(DateTime date) {
    final j = toNative(date)!;
    return (j.year, j.month, j.day);
  }

  @override
  DateTime fromYearMonthDay(int? year, int? month, int? day) {
    return Jalali(year ?? 1, month ?? 1, day ?? 1).toDateTime();
  }

  @override
  int yearDelta(DateTime startDate, DateTime endDate) {
    final jStart = toNative(startDate)!;
    final jEnd = toNative(endDate)!;
    return jEnd.year - jStart.year;
  }

  @override
  int monthDelta(DateTime startDate, DateTime endDate) {
    final jStart = toNative(startDate)!;
    final jEnd = toNative(endDate)!;
    return (jEnd.year - jStart.year) * monthsPerYear + jEnd.month - jStart.month;
  }
}
