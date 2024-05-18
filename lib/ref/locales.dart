import 'dart:ui';

const String asciiLocale = 'en_US';

// cf https://en.wikipedia.org/wiki/Eastern_Arabic_numerals
bool shouldUseNativeDigits(Locale? countrifiedLocale) {
  switch (countrifiedLocale?.toString()) {
    // Maghreb
    case 'ar_DZ': // Algeria
    case 'ar_EH': // Western Sahara
    case 'ar_LY': // Libya
    case 'ar_MA': // Morocco
    case 'ar_MR': // Mauritania
    case 'ar_TN': // Tunisia
      return false;
    // Mashriq
    case 'ar_AE': // United Arab Emirates
    case 'ar_BH': // Bahrain
    case 'ar_EG': // Egypt
    case 'ar_IQ': // Iraq
    case 'ar_JO': // Jordan
    case 'ar_KW': // Kuwait
    case 'ar_LB': // Lebanon
    case 'ar_OM': // Oman
    case 'ar_PS': // Palestinian Territories
    case 'ar_QA': // Qatar
    case 'ar_SA': // Saudi Arabia
    case 'ar_SD': // Sudan
    case 'ar_SS': // South Sudan
    case 'ar_SY': // Syria
    case 'ar_YE': // Yemen
      return true;
    // Horn of Africa
    case 'ar_DJ': // Djibouti
    case 'ar_ER': // Eritrea
    case 'ar_KM': // Comoros
    case 'ar_SO': // Somalia
      return true;
    // others
    case 'ar_IL': // Israel
    case 'ar_TD': // Chad
      return true;
    case null:
    default:
      return true;
  }
}

bool canHaveLetterSpacing(String locale) {
  switch (locale) {
    case 'ar':
    case 'fa':
      return false;
    default:
      return true;
  }
}
