import 'package:intl4x/datetime_format.dart';

class Intl4x {
  static Locale toLocale4x(String languageBcp47, Calendar calendar, bool forceWesternArabicNumerals) {
    var locale = Locale.parse(languageBcp47).withCalendar(calendar);
    if (forceWesternArabicNumerals) {
      locale = locale.withNumberingSystem(NumberingSystem.latin);
    }
    return locale;
  }
}
