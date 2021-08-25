extension ExtraDateTime on DateTime {
  bool isAtSameYearAs(DateTime? other) => year == other?.year;

  bool isAtSameMonthAs(DateTime? other) => isAtSameYearAs(other) && month == other?.month;

  bool isAtSameDayAs(DateTime? other) => isAtSameMonthAs(other) && day == other?.day;

  bool get isToday => isAtSameDayAs(DateTime.now());

  bool get isYesterday => isAtSameDayAs(DateTime.now().subtract(const Duration(days: 1)));

  bool get isThisMonth => isAtSameMonthAs(DateTime.now());

  bool get isThisYear => isAtSameYearAs(DateTime.now());
}
