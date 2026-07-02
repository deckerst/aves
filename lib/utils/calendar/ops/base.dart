abstract class CalendarOps {
  // when `DateTime` components are to be interpreted within the calendar
  // e.g. when `DateTime` month `7` is to be interpreted as Persian 7th month `Mehr`
  DateTime asNative(DateTime date);

  DateTime dateOnly(DateTime date);

  DateTime monthDateOnly(DateTime date);

  DateTime yearDateOnly(DateTime date);

  DateTime addDaysToDate(DateTime date, int days);

  DateTime addMonthsToMonthDate(DateTime monthDate, int months);

  DateTime addYearsToYearDate(DateTime yearDate, int years);

  bool isSameYear(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonth(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB);

  bool isOnMonthDay(DateTime? date, int month, int day);

  bool isOnMonth(DateTime? date, int month);

  bool isOnDay(DateTime? date, int day);

  (int year, int month) getYearMonth(DateTime date);

  (int year, int month, int day) getYearMonthDay(DateTime date);

  DateTime fromYearMonthDay(int? year, int? month, int? day);

  bool isToday(DateTime date) => isSameYearMonthDay(date, DateTime.now());

  bool isYesterday(DateTime date) => isSameYearMonthDay(date, DateTime.now().subtract(const Duration(days: 1)));

  bool isThisMonth(DateTime date) => isSameYearMonth(date, DateTime.now());

  bool isThisYear(DateTime date) => isSameYear(date, DateTime.now());
}
