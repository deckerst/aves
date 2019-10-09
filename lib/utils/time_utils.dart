bool isAtSameYearAs(DateTime d1, DateTime d2) => d1 != null && d2 != null && d1.year == d2.year;

bool isAtSameMonthAs(DateTime d1, DateTime d2) => isAtSameYearAs(d1, d2) && d1.month == d2.month;

bool isAtSameDayAs(DateTime d1, DateTime d2) => isAtSameMonthAs(d1, d2) && d1.day == d2.day;

bool isToday(DateTime d) => isAtSameDayAs(d, DateTime.now());

bool isThisMonth(DateTime d) => isAtSameMonthAs(d, DateTime.now());

bool isThisYear(DateTime d) => isAtSameYearAs(d, DateTime.now());

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
