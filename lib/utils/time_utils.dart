String formatDuration(Duration d) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitSeconds = twoDigits(d.inSeconds.remainder(Duration.secondsPerMinute));
  if (d.inHours == 0) return '${d.inMinutes}:$twoDigitSeconds';

  final twoDigitMinutes = twoDigits(d.inMinutes.remainder(Duration.minutesPerHour));
  return '${d.inHours}:$twoDigitMinutes:$twoDigitSeconds';
}

extension ExtraDateTime on DateTime {
  bool isAtSameYearAs(DateTime other) => this != null && other != null && year == other.year;

  bool isAtSameMonthAs(DateTime other) => isAtSameYearAs(other) && month == other.month;

  bool isAtSameDayAs(DateTime other) => isAtSameMonthAs(other) && day == other.day;

  bool get isToday => isAtSameDayAs(DateTime.now());

  bool get isYesterday => isAtSameDayAs(DateTime.now().subtract(Duration(days: 1)));

  bool get isThisMonth => isAtSameMonthAs(DateTime.now());

  bool get isThisYear => isAtSameYearAs(DateTime.now());
}
