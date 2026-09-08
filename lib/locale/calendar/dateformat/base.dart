// ignore_for_file: non_constant_identifier_names
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
abstract class DateFormatDelegate {
  final String languageTag;

  const new({required this.languageTag});

  DateFormatter get y;

  DateFormatter get MMM;

  DateFormatter get MMMM;

  DateFormatter get d;

  DateFormatter get MMMd;

  DateFormatter get MMMMd;

  DateFormatter get yMMM;

  DateFormatter get yMMMM;

  DateFormatter get MMMEd;

  DateFormatter get yMd;

  DateFormatter get yMMMd;

  DateFormatter get yMMMMd;

  DateFormatter get yMMMMEEEEd;

  DateFormatter get Hm;

  DateFormatter get jm;
}
