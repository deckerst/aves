// ignore_for_file: non_constant_identifier_names
import 'package:aves/locale/aves_locale.dart';
import 'package:aves/locale/calendar/dateformat/base.dart';
import 'package:aves/locale/intl4x.dart';
import 'package:intl4x/datetime_format.dart';

class Intl4xDateFormatDelegate extends DateFormatDelegate {
  final Locale _locale4x;

  new({
    required super.languageTag,
    required ACalendar calendar,
    required bool forceWesternArabicNumerals,
  }) : _locale4x = Intl4x.toLocale4x(languageTag, calendar, forceWesternArabicNumerals);

  @override
  DateFormatter get y => DateTimeFormat.year(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get MMM => DateTimeFormat.month(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get MMMM => DateTimeFormat.month(
    locale: _locale4x,
    length: DateTimeLength.long,
  ).format;

  @override
  DateFormatter get d => DateTimeFormat.day(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get MMMd => DateTimeFormat.monthDay(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get MMMMd => DateTimeFormat.monthDay(
    locale: _locale4x,
    length: DateTimeLength.long,
  ).format;

  // ideally, we would use an equivalent to intl `DateFormat.yMMM`,
  // but as of intl4x v1.0.0-alpha.2, there is no `DateTimeFormat.yearMonth`
  @override
  DateFormatter get yMMM {
    final y = DateTimeFormat.year(
      locale: _locale4x,
      length: DateTimeLength.medium,
    );
    final d = DateTimeFormat.month(
      locale: _locale4x,
      length: DateTimeLength.medium,
    );
    return (v) => '${y.format(v)} ${d.format(v)}';
  }

  // ideally, we would use an equivalent to intl `DateFormat.yMMMM`,
  // but as of intl4x v1.0.0-alpha.2, there is no `DateTimeFormat.yearMonth`
  @override
  DateFormatter get yMMMM {
    final y = DateTimeFormat.year(
      locale: _locale4x,
      length: DateTimeLength.long,
    );
    final d = DateTimeFormat.month(
      locale: _locale4x,
      length: DateTimeLength.long,
    );
    return (v) => '${y.format(v)} ${d.format(v)}';
  }

  // ideally, we would use an equivalent to intl `DateFormat.MMMEd`,
  // but as of intl4x v1.0.0-alpha.2, there is no `DateTimeFormat.monthDayWeekday`
  @override
  DateFormatter get MMMEd => DateTimeFormat.yearMonthDayWeekday(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get yMd => DateTimeFormat.yearMonthDay(
    locale: _locale4x,
    length: DateTimeLength.short,
  ).format;

  @override
  DateFormatter get yMMMd => DateTimeFormat.yearMonthDay(
    locale: _locale4x,
    length: DateTimeLength.medium,
  ).format;

  @override
  DateFormatter get yMMMMd => DateTimeFormat.yearMonthDay(
    locale: _locale4x,
    length: DateTimeLength.long,
  ).format;

  @override
  DateFormatter get yMMMMEEEEd => DateTimeFormat.yearMonthDayWeekday(
    locale: _locale4x,
    length: DateTimeLength.long,
  ).format;

  @override
  DateFormatter get Hm => DateTimeFormat.time(
    locale: _locale4x.withClockStyle(ClockStyle.zeroToTwentyThree),
    length: DateTimeLength.medium,
    timePrecision: TimePrecision.minute,
  ).format;

  @override
  DateFormatter get jm => DateTimeFormat.time(
    locale: _locale4x.withClockStyle(ClockStyle.zeroToEleven),
    length: DateTimeLength.medium,
    timePrecision: TimePrecision.minute,
  ).format;
}
