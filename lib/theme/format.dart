import 'package:aves/theme/text.dart';
import 'package:intl/intl.dart';

String formatDay(DateTime date, String locale) => DateFormat.yMMMd(locale).format(date);

String formatTime(DateTime date, String locale, bool use24hour) => (use24hour ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(date);

String formatDateTime(DateTime date, String locale, bool use24hour) => [
      formatDay(date, locale),
      formatTime(date, locale, use24hour),
    ].join(AText.separator);

String formatFriendlyDuration(Duration d) {
  final seconds = (d.inSeconds.remainder(Duration.secondsPerMinute)).toString().padLeft(2, '0');
  if (d.inHours == 0) return '${d.inMinutes}:$seconds';

  final minutes = (d.inMinutes.remainder(Duration.minutesPerHour)).toString().padLeft(2, '0');
  return '${d.inHours}:$minutes:$seconds';
}

String formatPreciseDuration(Duration d) {
  final millis = ((d.inMicroseconds / 1000.0).round() % 1000).toString().padLeft(3, '0');
  final seconds = (d.inSeconds.remainder(Duration.secondsPerMinute)).toString().padLeft(2, '0');
  final minutes = (d.inMinutes.remainder(Duration.minutesPerHour)).toString().padLeft(2, '0');
  final hours = (d.inHours).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds.$millis';
}
