// this class is kept minimal, without import
// so it can be reused in driver tests

class const KnownLocale({
  // BCP 47 language tag: https://en.wikipedia.org/wiki/IETF_language_tag
  required final String bcp47,
  required final String endonym,
}) {
  static const english = KnownLocale(bcp47: 'en', endonym: 'English');

  // distinct from:
  // - `AppLocalizations.supportedLocales`: localed automatically created as soon as l10n files exist
  // - `AvesApp.supportedLocales`: locales derived from `AppLocalizations`, without explicitly excluded ones
  static const all = [
    KnownLocale(bcp47: 'ar', endonym: 'العربية'),
    KnownLocale(bcp47: 'be', endonym: 'Беларуская мова'),
    KnownLocale(bcp47: 'bg', endonym: 'Български'),
    KnownLocale(bcp47: 'ca', endonym: 'Català'),
    KnownLocale(bcp47: 'cs', endonym: 'Čeština'),
    KnownLocale(bcp47: 'da', endonym: 'Dansk'),
    KnownLocale(bcp47: 'de', endonym: 'Deutsch'),
    KnownLocale(bcp47: 'el', endonym: 'Ελληνικά'),
    english,
    KnownLocale(bcp47: 'en-Shaw', endonym: '𐑦𐑙𐑜𐑤𐑦𐑖 (𐑖𐑱𐑝𐑰𐑩𐑯)'),
    KnownLocale(bcp47: 'es', endonym: 'Español (México)'),
    KnownLocale(bcp47: 'et', endonym: 'Eesti'),
    KnownLocale(bcp47: 'eu', endonym: 'Euskara'),
    KnownLocale(bcp47: 'fa', endonym: 'فارسی'),
    KnownLocale(bcp47: 'fr', endonym: 'Français'),
    KnownLocale(bcp47: 'fi', endonym: 'Suomi'),
    KnownLocale(bcp47: 'gl', endonym: 'Galego'),
    KnownLocale(bcp47: 'hu', endonym: 'Magyar'),
    KnownLocale(bcp47: 'id', endonym: 'Bahasa Indonesia'),
    KnownLocale(bcp47: 'is', endonym: 'Íslenska'),
    KnownLocale(bcp47: 'it', endonym: 'Italiano'),
    KnownLocale(bcp47: 'ja', endonym: '日本語'),
    KnownLocale(bcp47: 'kmr', endonym: 'Kurdî (Kurmancî)'),
    KnownLocale(bcp47: 'kn', endonym: 'ಕನ್ನಡ'),
    KnownLocale(bcp47: 'ko', endonym: '한국어'),
    KnownLocale(bcp47: 'lo', endonym: 'ພາສາລາວ'),
    KnownLocale(bcp47: 'lt', endonym: 'Lietuvių'),
    KnownLocale(bcp47: 'nb', endonym: 'Norsk (Bokmål)'),
    KnownLocale(bcp47: 'nn', endonym: 'Norsk (Nynorsk)'),
    KnownLocale(bcp47: 'nl', endonym: 'Nederlands'),
    KnownLocale(bcp47: 'pl', endonym: 'Polski'),
    KnownLocale(bcp47: 'pt', endonym: 'Português (Brasil)'),
    KnownLocale(bcp47: 'ro', endonym: 'Română'),
    KnownLocale(bcp47: 'ru', endonym: 'Русский'),
    KnownLocale(bcp47: 'sk', endonym: 'Slovenčina'),
    KnownLocale(bcp47: 'sv', endonym: 'Svenska'),
    KnownLocale(bcp47: 'ta', endonym: 'தமிழ்'),
    KnownLocale(bcp47: 'th', endonym: 'ไทย'),
    KnownLocale(bcp47: 'tr', endonym: 'Türkçe'),
    KnownLocale(bcp47: 'uk', endonym: 'Українська'),
    KnownLocale(bcp47: 'ur', endonym: 'اُردُو'),
    KnownLocale(bcp47: 'vi', endonym: 'Tiếng Việt'),
    KnownLocale(bcp47: 'zh', endonym: '简体中文'),
    KnownLocale(bcp47: 'zh-Hant', endonym: '繁體中文'),
  ];
}
