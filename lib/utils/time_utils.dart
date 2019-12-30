String formatDuration(Duration d) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitSeconds = twoDigits(d.inSeconds.remainder(Duration.secondsPerMinute));
  if (d.inHours == 0) return '${d.inMinutes}:$twoDigitSeconds';

  String twoDigitMinutes = twoDigits(d.inMinutes.remainder(Duration.minutesPerHour));
  return '${d.inHours}:$twoDigitMinutes:$twoDigitSeconds';
}

extension ExtraDateTime on DateTime {
  bool isAtSameYearAs(DateTime other) => this != null && other != null && this.year == other.year;

  bool isAtSameMonthAs(DateTime other) => isAtSameYearAs(other) && this.month == other.month;

  bool isAtSameDayAs(DateTime other) => isAtSameMonthAs(other) && this.day == other.day;

  bool get isToday => isAtSameDayAs(DateTime.now());

  bool get isYesterday => isAtSameDayAs(DateTime.now().subtract(const Duration(days: 1)));

  bool get isThisMonth => isAtSameMonthAs(DateTime.now());

  bool get isThisYear => isAtSameYearAs(DateTime.now());
}
