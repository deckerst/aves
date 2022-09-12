import 'package:flutter/foundation.dart';

extension ExtraDateTime on DateTime {
  bool isAtSameYearAs(DateTime? other) => year == other?.year;

  bool isAtSameMonthAs(DateTime? other) => isAtSameYearAs(other) && month == other?.month;

  bool isAtSameDayAs(DateTime? other) => isAtSameMonthAs(other) && day == other?.day;

  bool get isToday => isAtSameDayAs(DateTime.now());

  bool get isYesterday => isAtSameDayAs(DateTime.now().subtract(const Duration(days: 1)));

  bool get isThisMonth => isAtSameMonthAs(DateTime.now());

  bool get isThisYear => isAtSameYearAs(DateTime.now());

  DateTime get date => DateTime(year, month, day);

  DateTime addMonths(int months) => DateTime(year, month + months, day, hour, minute, second, millisecond, microsecond);

  DateTime addDays(int days) => DateTime(year, month, day + days, hour, minute, second, millisecond, microsecond);
}

final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

// Overflowing timestamps that are supposed to be in milliseconds
// will be retried after stripping extra digits.
const _millisMaxDigits = 13; // 13 digits can go up to 2286/11/20

DateTime? dateTimeFromMillis(int? millis, {bool isUtc = false}) {
  if (millis == null || millis == 0) return null;
  try {
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: isUtc);
  } catch (e) {
    // `DateTime`s can represent time values that are at a distance of at most 100,000,000
    // days from epoch (1970-01-01 UTC): -271821-04-20 to 275760-09-13.
    debugPrint('failed to build DateTime from timestamp in millis=$millis');
  }
  final digits = '$millis'.length;
  if (digits > _millisMaxDigits) {
    millis = int.tryParse('$millis'.substring(0, _millisMaxDigits));
    return dateTimeFromMillis(millis, isUtc: isUtc);
  }
  return null;
}

final _unixStampMillisPattern = RegExp(r'\d{13}');
final _unixStampSecPattern = RegExp(r'\d{10}');
final _dateYMD8Hms6Sub3Pattern = RegExp(r'(\d{8})([_-\s](\d{6})([_-\s](\d{3}))?)?');
final _dateY4M2D2H2m2s2Sub3Pattern = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})[ -](\d{1,2})[.-](\d{1,2})[.-](\d{1,2})[.-](\d{1,3})?');
final _dateY4M2D2Hms6Pattern = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2}) (\d{6})');

DateTime? parseUnknownDateFormat(String? s) {
  if (s == null) return null;

  var match = _unixStampMillisPattern.firstMatch(s);
  if (match != null) {
    final stampMillisString = match.group(0);
    if (stampMillisString != null) {
      final stampMillis = int.tryParse(stampMillisString);
      if (stampMillis != null) {
        return dateTimeFromMillis(stampMillis, isUtc: false);
      }
    }
  }

  match = _unixStampSecPattern.firstMatch(s);
  if (match != null) {
    final stampSecString = match.group(0);
    if (stampSecString != null) {
      final stampSec = int.tryParse(stampSecString);
      if (stampSec != null) {
        return dateTimeFromMillis(stampSec * 1000, isUtc: false);
      }
    }
  }

  match = _dateYMD8Hms6Sub3Pattern.firstMatch(s);
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

  match = _dateY4M2D2H2m2s2Sub3Pattern.firstMatch(s);
  if (match != null) {
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    final hour = int.tryParse(match.group(4)!);
    final minute = int.tryParse(match.group(5)!);
    final second = int.tryParse(match.group(6)!);
    final millis = match.groupCount >= 7 ? int.tryParse(match.group(7) ?? '0') : 0;

    if (year != null && month != null && day != null && hour != null && minute != null && second != null && millis != null) {
      return DateTime(year, month, day, hour, minute, second, millis);
    }
  }

  match = _dateY4M2D2Hms6Pattern.firstMatch(s);
  if (match != null) {
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    final timeString = match.group(4);

    var hour = 0, minute = 0, second = 0;
    if (timeString != null) {
      hour = int.tryParse(timeString.substring(0, 2)) ?? 0;
      minute = int.tryParse(timeString.substring(2, 4)) ?? 0;
      second = int.tryParse(timeString.substring(4, 6)) ?? 0;
    }

    if (year != null && month != null && day != null) {
      return DateTime(year, month, day, hour, minute, second);
    }
  }

  return null;
}
