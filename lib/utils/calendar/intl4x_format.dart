// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

typedef DateFormatter = String Function(DateTime date);

/*
  * `intl` formatter examples (en_US)

  `MMMMd`:       `April 15`
  `yMMMMd`:      `April 15, 2020`
  `MMMEd`:       `Wed, Apr 15`
  `yMMMEd`:      `Wed, Apr 15, 2020`
  `MMMMEEEEd`:   `Wednesday, April 15`
  `yMMMMEEEEd`:  `Wednesday, April 15, 2020`
  `MEd`:         `Wed, 4/15`
  `yMEd`:        `Wed, 4/15/2020`

  * `intl` formatter examples (ko)

  `MMMMd`:       `1월 26일`
  `yMMMMd`:      `2021년 1월 26일`
  `MMMEd`:       `1월 26일 (화)`
  `yMMMEd`:      `2021년 1월 26일 (화)`
  `MMMMEEEEd`:   `1월 26일 화요일`
  `yMMMMEEEEd`:  `2021년 1월 26일 화요일`
  `MEd`:         `1. 26. (화)`
  `yMEd`:        `2021. 1. 26. (화)`

  * `intl4x` formatter examples (en-US locale, Gregorian calendar)

  year / short:   14
  year / medium:  2014
  year / long:    2014

  month / short:  3
  month / medium: Mar
  month / long:   March

  day / short:    1
  day / medium:   1
  day / long:     1

  monthDay / short:       3/1
  monthDay / medium:      Mar 1
  monthDay / long:        March 1

  yearMonthDay / short:   3/1/14
  yearMonthDay / medium:  Mar 1, 2014
  yearMonthDay / long:    March 1, 2014
 */
extension ExtraIntl4xCalendarFormat on intl4x.Locale {
  // cf intl `DateFormat.y(locale)`
  DateFormatter y() {
    return intl4x.DateTimeFormat.year(
      locale: this,
      length: intl4x.DateTimeLength.medium,
    ).format;
  }

  // cf intl `DateFormat.MMM(locale)`
  DateFormatter MMM() {
    return intl4x.DateTimeFormat.month(
      locale: this,
      length: intl4x.DateTimeLength.medium,
    ).format;
  }

  // cf intl `DateFormat.MMMM(locale)`
  DateFormatter MMMM() {
    return intl4x.DateTimeFormat.month(
      locale: this,
      length: intl4x.DateTimeLength.long,
    ).format;
  }

  // cf intl `DateFormat.d(locale)`
  DateFormatter d() {
    return intl4x.DateTimeFormat.day(
      locale: this,
      length: intl4x.DateTimeLength.medium,
    ).format;
  }

  // cf intl `DateFormat.MMMd(locale)`
  DateFormatter MMMd() {
    return intl4x.DateTimeFormat.monthDay(
      locale: this,
      length: intl4x.DateTimeLength.medium,
    ).format;
  }

  // cf intl `DateFormat.MMMMd(locale)`
  DateFormatter MMMMd() {
    return intl4x.DateTimeFormat.monthDay(
      locale: this,
      length: intl4x.DateTimeLength.long,
    ).format;
  }

  DateFormatter yMMM(String localeName, intl4x.Calendar calendar) {
    switch (calendar) {
      case .gregorian:
        return DateFormat.yMMM().format;
      default:
        // ideally, we would use an equivalent to intl `DateFormat.yMMM`,
        // but as of intl4x v0.17.0, there is no `DateTimeFormat.yearMonth`
        final locale4x = this;
        final y = intl4x.DateTimeFormat.year(
          locale: locale4x,
          length: intl4x.DateTimeLength.medium,
        );
        final d = intl4x.DateTimeFormat.month(
          locale: locale4x,
          length: intl4x.DateTimeLength.medium,
        );
        return (v) => '${y.format(v)} ${d.format(v)}';
    }
  }

  DateFormatter yMMMM(String localeName, intl4x.Calendar calendar) {
    switch (calendar) {
      case .gregorian:
        return DateFormat.yMMMM(localeName).format;
      default:
        // ideally, we would use an equivalent to intl `DateFormat.yMMMM`,
        // but as of intl4x v0.17.0, there is no `DateTimeFormat.yearMonth`
        final locale4x = this;
        final y = intl4x.DateTimeFormat.year(
          locale: locale4x,
          length: intl4x.DateTimeLength.long,
        );
        final d = intl4x.DateTimeFormat.month(
          locale: locale4x,
          length: intl4x.DateTimeLength.long,
        );
        return (v) => '${y.format(v)} ${d.format(v)}';
    }
  }

  DateFormatter MMMEd(String localeName, intl4x.Calendar calendar) {
    switch (calendar) {
      case .gregorian:
        return DateFormat.MMMEd(localeName).format;
      default:
        // ideally, we would use an equivalent to intl `DateFormat.MMMEd`,
        // but as of intl4x v0.17.0, there is no `DateTimeFormat.monthDayWeekday`
        final locale4x = this;
        final ymdw = intl4x.DateTimeFormat.yearMonthDayWeekday(
          locale: locale4x,
          length: intl4x.DateTimeLength.medium,
        );
        return ymdw.format;
    }
  }

  // cf intl `DateFormat.yMd(locale)`
  DateFormatter yMd() {
    return intl4x.DateTimeFormat.yearMonthDay(
      locale: this,
      length: intl4x.DateTimeLength.short,
    ).format;
  }

  // cf intl `DateFormat.yMMMd(locale)`
  DateFormatter yMMMd() {
    return intl4x.DateTimeFormat.yearMonthDay(
      locale: this,
      length: intl4x.DateTimeLength.medium,
    ).format;
  }

  // cf intl `DateFormat.yMMMMd(locale)`
  DateFormatter yMMMMd() {
    return intl4x.DateTimeFormat.yearMonthDay(
      locale: this,
      length: intl4x.DateTimeLength.long,
    ).format;
  }

  // cf intl `DateFormat.yMMMMEEEEd(locale)`
  DateFormatter yMMMMEEEEd() {
    return intl4x.DateTimeFormat.yearMonthDayWeekday(
      locale: this,
      length: intl4x.DateTimeLength.long,
    ).format;
  }

  // cf intl `DateFormat.Hm(locale)`
  DateFormatter Hm() {
    return intl4x.DateTimeFormat.time(
      locale: withClockStyle(intl4x.ClockStyle.zeroToTwentyThree),
      length: intl4x.DateTimeLength.medium,
      timePrecision: intl4x.TimePrecision.minute,
    ).format;
  }

  // cf intl `DateFormat.jm(locale)`
  DateFormatter jm() {
    return intl4x.DateTimeFormat.time(
      locale: withClockStyle(intl4x.ClockStyle.zeroToEleven),
      length: intl4x.DateTimeLength.medium,
      timePrecision: intl4x.TimePrecision.minute,
    ).format;
  }
}
