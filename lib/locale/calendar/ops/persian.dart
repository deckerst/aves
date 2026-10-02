import 'package:aves/locale/calendar/ops/base.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PersianCalendarOps extends CalendarOps {
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
    final native = toNative(date)!.copy(hour: 0, minute: 0, second: 0, millisecond: 0);
    return native.toDateTime();
  }

  @override
  DateTime monthDateOnly(DateTime date) {
    final native = toNative(date)!.copy(day: 1, hour: 0, minute: 0, second: 0, millisecond: 0);
    return native.toDateTime();
  }

  @override
  DateTime yearDateOnly(DateTime date) {
    final native = toNative(date)!.copy(month: 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 0);
    return native.toDateTime();
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) {
    final native = toNative(date)!.addDays(days);
    return native.toDateTime();
  }

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int months) {
    final native = toNative(monthDate)!.addMonths(months);
    return native.toDateTime();
  }

  @override
  DateTime addYearsToYearDate(DateTime yearDate, int years) {
    final native = toNative(yearDate)!.addYears(years);
    return native.toDateTime();
  }

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) {
    final nativeA = toNative(dateA);
    final nativeB = toNative(dateB);
    return nativeA?.year == nativeB?.year;
  }

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) {
    final nativeA = toNative(dateA);
    final nativeB = toNative(dateB);
    return nativeA?.year == nativeB?.year && nativeA?.month == nativeB?.month;
  }

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) {
    final nativeA = toNative(dateA);
    final nativeB = toNative(dateB);
    return nativeA?.year == nativeB?.year && nativeA?.month == nativeB?.month && nativeA?.day == nativeB?.day;
  }

  @override
  bool isOnMonthDay(DateTime? date, int month, int day) {
    final nativeA = toNative(date);
    return nativeA?.month == month && nativeA?.day == day;
  }

  @override
  bool isOnMonth(DateTime? date, int month) {
    final nativeA = toNative(date);
    return nativeA?.month == month;
  }

  @override
  bool isOnDay(DateTime? date, int day) {
    final nativeA = toNative(date);
    return nativeA?.day == day;
  }

  @override
  int getYear(DateTime date) {
    final native = toNative(date)!;
    return native.year;
  }

  @override
  (int year, int month) getYearMonth(DateTime date) {
    final native = toNative(date)!;
    return (native.year, native.month);
  }

  @override
  (int year, int month, int day) getYearMonthDay(DateTime date) {
    final native = toNative(date)!;
    return (native.year, native.month, native.day);
  }

  @override
  DateTime fromYearMonthDay(int? year, int? month, int? day) {
    return Jalali(year ?? 1, month ?? 1, day ?? 1).toDateTime();
  }

  @override
  int yearDelta(DateTime startDate, DateTime endDate) {
    final nativeStart = toNative(startDate)!;
    final nativeEnd = toNative(endDate)!;
    return nativeEnd.year - nativeStart.year;
  }

  @override
  int monthDelta(DateTime startDate, DateTime endDate) {
    final nativeStart = toNative(startDate)!;
    final nativeEnd = toNative(endDate)!;
    return (nativeEnd.year - nativeStart.year) * monthsPerYear + nativeEnd.month - nativeStart.month;
  }
}
