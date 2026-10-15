import 'package:aves/locale/ui.dart';

// `Intl` locale name is possibly BCP 47, possibly `xx_YY`
// without guaranteed case nor separator (cf `Intl.canonicalizedLocale()`)
class IntlUtils {
  static final _separators = RegExp(r'[_-]+');

  static String rootLocaleName = rootLocale.toLanguageTag();

  static String getLanguageSubTag(String localeName) => localeName.split(_separators)[0].toLowerCase();
}
