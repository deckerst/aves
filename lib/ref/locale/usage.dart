import 'package:aves/ref/locale/iso639_1.dart';
import 'package:country_code/country_code.dart';

class LocaleUsage {
  static const _defaultNativeDigits = true;

  // cf https://en.wikipedia.org/wiki/Eastern_Arabic_numerals
  static bool shouldUseNativeDigits(String? languageSubtag, String? countrySubtag) {
    switch (languageSubtag?.toLowerCase()) {
      case LanguageCodesIso639_1.arabic:
        final countryUpper = countrySubtag?.toUpperCase();
        if (countryUpper == null) return _defaultNativeDigits;

        switch (CountryCode.tryParse(countryUpper)) {
          // Maghreb
          case CountryCode.DZ: // Algeria
          case CountryCode.EH: // Western Sahara
          case CountryCode.LY: // Libya
          case CountryCode.MA: // Morocco
          case CountryCode.MR: // Mauritania
          case CountryCode.TN: // Tunisia
            return false;
          // Mashriq
          case CountryCode.AE: // United Arab Emirates
          case CountryCode.BH: // Bahrain
          case CountryCode.EG: // Egypt
          case CountryCode.IQ: // Iraq
          case CountryCode.JO: // Jordan
          case CountryCode.KW: // Kuwait
          case CountryCode.LB: // Lebanon
          case CountryCode.OM: // Oman
          case CountryCode.PS: // Palestinian Territories
          case CountryCode.QA: // Qatar
          case CountryCode.SA: // Saudi Arabia
          case CountryCode.SD: // Sudan
          case CountryCode.SS: // South Sudan
          case CountryCode.SY: // Syria
          case CountryCode.YE: // Yemen
            return true;
          // Horn of Africa
          case CountryCode.DJ: // Djibouti
          case CountryCode.ER: // Eritrea
          case CountryCode.KM: // Comoros
          case CountryCode.SO: // Somalia
            return true;
          // others
          case CountryCode.IL: // Israel
          case CountryCode.TD: // Chad
            return true;
          case null:
          default:
            return _defaultNativeDigits;
        }
      case null:
      default:
        return _defaultNativeDigits;
    }
  }
}
