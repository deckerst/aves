import 'package:aves/locale/calendar/ops/base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hijri_rrule/flutter_hijri_rrule.dart';

class HijriCalendarOps extends CalendarOps {
  static final tabular = HijriCalendarOps._private(.islamicTbla);
  static final umalqura = HijriCalendarOps._private(.islamicUmalqura);

  final IslamicCalendarType _calendarType;

  new _private(this._calendarType);

  HijriDate? toNative(DateTime? date) => date != null ? HijriDate.fromGregorian(date, _calendarType) : null;

  @override
  DateTime asNative(DateTime date) => HijriDate(
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  ).toGregorian(_calendarType).copyWith(millisecond: date.millisecond);

  @override
  DateTime dateOnly(DateTime date) {
    final native = toNative(date)!.copyWith(hour: 0, minute: 0, second: 0, calendar: _calendarType);
    return native.toGregorian(_calendarType);
  }

  @override
  DateTime monthDateOnly(DateTime date) {
    final native = toNative(date)!.copyWith(day: 1, hour: 0, minute: 0, second: 0, calendar: _calendarType);
    return native.toGregorian(_calendarType);
  }

  @override
  DateTime yearDateOnly(DateTime date) {
    final native = toNative(date)!.copyWith(month: 1, day: 1, hour: 0, minute: 0, second: 0, calendar: _calendarType);
    return native.toGregorian(_calendarType);
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) {
    final native = addDays(toNative(date)!, days, calendar: _calendarType);
    return native.toGregorian(_calendarType);
  }

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int months) {
    final native = addMonths(toNative(monthDate)!, months, calendar: _calendarType);
    return native!.toGregorian(_calendarType);
  }

  @override
  DateTime addYearsToYearDate(DateTime yearDate, int years) {
    final native = addYears(toNative(yearDate)!, years, calendar: _calendarType);
    return native!.toGregorian(_calendarType);
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
    try {
      final native = toNative(date)!;
      return (native.year, native.month);
    } catch(ex) {
      debugPrint('TLAD getYearMonth fail for date=$date');
      rethrow;
    }
  }

  @override
  (int year, int month, int day) getYearMonthDay(DateTime date) {
    final native = toNative(date)!;
    return (native.year, native.month, native.day);
  }

  @override
  DateTime fromYearMonthDay(int? year, int? month, int? day) {
    return HijriDate(year ?? 1, month ?? 1, day ?? 1).toGregorian(_calendarType);
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
