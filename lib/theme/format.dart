import 'package:aves/theme/text.dart';
import 'package:intl/intl.dart';

String formatDay(DateTime date, String locale) => DateFormat.yMMMd(locale).format(date);

String formatTime(DateTime date, String locale, bool use24hour) => (use24hour ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(date);

String formatDateTime(DateTime date, String locale, bool use24hour) => [
      formatDay(date, locale),
      formatTime(date, locale, use24hour),
    ].join(AText.separator);

String formatFriendlyDuration(Duration d) {
  final isNegative = d.isNegative;
  final sign = isNegative ? '-' : '';
  d = d.abs();
  final hours = d.inHours;
  d -= Duration(hours: hours);
  final minutes = d.inMinutes;
  d -= Duration(minutes: minutes);
  final seconds = d.inSeconds;

  if (hours == 0) return '$sign$minutes:${seconds.toString().padLeft(2, '0')}';

  return '$sign$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatPreciseDuration(Duration d) {
  final millis = ((d.inMicroseconds / 1000.0).round() % 1000).toString().padLeft(3, '0');
  final seconds = (d.inSeconds.remainder(Duration.secondsPerMinute)).toString().padLeft(2, '0');
  final minutes = (d.inMinutes.remainder(Duration.minutesPerHour)).toString().padLeft(2, '0');
  final hours = (d.inHours).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds.$millis';
}
