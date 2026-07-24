import 'package:intl4x/datetime_format.dart';

class Intl4x {
  static Locale toLocale4x(String languageTag, Calendar calendar, bool forceWesternArabicNumerals) {
    var locale = Locale.parse(languageTag).withCalendar(calendar);
    if (forceWesternArabicNumerals) {
      locale = locale.withNumberingSystem(NumberingSystem.latin);
    }
    return locale;
  }
}
