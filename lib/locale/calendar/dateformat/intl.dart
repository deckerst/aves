// ignore_for_file: non_constant_identifier_names
import 'package:aves/locale/calendar/dateformat/base.dart';
import 'package:intl/intl.dart';

class IntlDateFormatDelegate extends DateFormatDelegate {
  const new({required super.languageTag});

  @override
  DateFormatter get y => DateFormat.y(languageTag).format;

  @override
  DateFormatter get MMM => DateFormat.MMM(languageTag).format;

  @override
  DateFormatter get MMMM => DateFormat.MMMM(languageTag).format;

  @override
  DateFormatter get d => DateFormat.d(languageTag).format;

  @override
  DateFormatter get MMMd => DateFormat.MMMd(languageTag).format;

  @override
  DateFormatter get MMMMd => DateFormat.MMMMd(languageTag).format;

  @override
  DateFormatter get yMMM => DateFormat.yMMM(languageTag).format;

  @override
  DateFormatter get yMMMM => DateFormat.yMMMM(languageTag).format;

  @override
  DateFormatter get MMMEd => DateFormat.MMMEd(languageTag).format;

  @override
  DateFormatter get yMd => DateFormat.yMd(languageTag).format;

  @override
  DateFormatter get yMMMd => DateFormat.yMMMd(languageTag).format;

  @override
  DateFormatter get yMMMMd => DateFormat.yMMMMd(languageTag).format;

  @override
  DateFormatter get yMMMMEEEEd => DateFormat.yMMMMEEEEd(languageTag).format;

  @override
  DateFormatter get Hm => DateFormat.Hm(languageTag).format;

  @override
  DateFormatter get jm => DateFormat.jm(languageTag).format;
}
