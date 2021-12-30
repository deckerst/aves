extension ExtraDateTime on DateTime {
  bool isAtSameYearAs(DateTime? other) => year == other?.year;

  bool isAtSameMonthAs(DateTime? other) => isAtSameYearAs(other) && month == other?.month;

  bool isAtSameDayAs(DateTime? other) => isAtSameMonthAs(other) && day == other?.day;

  bool get isToday => isAtSameDayAs(DateTime.now());

  bool get isYesterday => isAtSameDayAs(DateTime.now().subtract(const Duration(days: 1)));

  bool get isThisMonth => isAtSameMonthAs(DateTime.now());

  bool get isThisYear => isAtSameYearAs(DateTime.now());
}

final _unixStampMillisPattern = RegExp(r'\d{13}');
final _unixStampSecPattern = RegExp(r'\d{10}');
final _plainPattern = RegExp(r'(\d{8})([_-\s](\d{6})([_-\s](\d{3}))?)?');

DateTime? parseUnknownDateFormat(String? s) {
  if (s == null) return null;

  var match = _unixStampMillisPattern.firstMatch(s);
  if (match != null) {
    final stampString = match.group(0);
    if (stampString != null) {
      final stampMillis = int.tryParse(stampString);
      if (stampMillis != null) {
        return DateTime.fromMillisecondsSinceEpoch(stampMillis, isUtc: false);
      }
    }
  }

  match = _unixStampSecPattern.firstMatch(s);
  if (match != null) {
    final stampString = match.group(0);
    if (stampString != null) {
      final stampMillis = int.tryParse(stampString);
      if (stampMillis != null) {
        return DateTime.fromMillisecondsSinceEpoch(stampMillis * 1000, isUtc: false);
      }
    }
  }

  match = _plainPattern.firstMatch(s);
  if (match != null) {
    final dateString = match.group(1);
    final timeString = match.group(3);
    final millisString = match.group(5);

    if (dateString != null) {
      final year = int.tryParse(dateString.substring(0, 4));
      final month = int.tryParse(dateString.substring(4, 6));
      final day = int.tryParse(dateString.substring(6, 8));

      if (year != null && month != null && day != null) {
        var hour = 0, minute = 0, second = 0, millis = 0;
        if (timeString != null) {
          hour = int.tryParse(timeString.substring(0, 2)) ?? 0;
          minute = int.tryParse(timeString.substring(2, 4)) ?? 0;
          second = int.tryParse(timeString.substring(4, 6)) ?? 0;

          if (millisString != null) {
            millis = int.tryParse(millisString) ?? 0;
          }
        }
        return DateTime(year, month, day, hour, minute, second, millis);
      }
    }
  }
}
