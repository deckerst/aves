import 'package:shamsi_date/shamsi_date.dart';

abstract class CalendarComparator {
  const CalendarComparator();

  bool isToday(DateTime date) => isSameYearMonthDay(date, DateTime.now());

  bool isYesterday(DateTime date) => isSameYearMonthDay(date, DateTime.now().subtract(const Duration(days: 1)));

  bool isThisMonth(DateTime date) => isSameYearMonth(date, DateTime.now());

  bool isThisYear(DateTime date) => isSameYear(date, DateTime.now());

  // when `DateTime` components are to be interpreted within the calendar
  // e.g. when `DateTime` month `7` is to be interpreted as Persian 7th month `Mehr`
  DateTime asNative(DateTime date);

  bool isSameYear(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonth(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB);

  bool isOnMonthDay(DateTime? date, int month, int day);

  bool isOnMonth(DateTime? date, int month);

  bool isOnDay(DateTime? date, int day);

  (int year, int month) getYearMonth(DateTime date);

  (int year, int month, int day) getYearMonthDay(DateTime date);

  DateTime fromYearMonthDay(int? year, int? month, int? day);
}

class GregorianCalendarComparator extends CalendarComparator {
  static final instance = GregorianCalendarComparator._private();

  GregorianCalendarComparator._private();

  @override
  DateTime asNative(DateTime date) => date;

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

class PersianCalendarComparator extends CalendarComparator {
  static final instance = PersianCalendarComparator._private();

  PersianCalendarComparator._private();

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

  Jalali? toNative(DateTime? date) => date?.toJalali();

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
}
