import 'package:aves/l10n/l10n.dart';
import 'package:aves/locale/intl.dart';
import 'package:aves/ref/locale/iso639_1.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension ExtraBuildContext on BuildContext {
  String? get currentRouteName => ModalRoute.of(this)?.settings.name;

  bool get isPortrait => MediaQuery.orientationOf(this) == .portrait;

  // l10n

  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // returns `xx_YY`, but case and separator are not guaranteed (cf `Intl.canonicalizedLocale()`)
  String get _localeIntlName => l10n.localeName;

  String get localeBcp47 => _localeIntlName.replaceAll('_', '-');

  KnownLocale? get knownLocale => KnownLocale.fromBcp47(localeBcp47);

  String get _languageSubtag => IntlUtils.getLanguageSubTag(l10n.localeName);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  String applyDirectionality(String text) => '$_directionalityMark$text';

  // cf https://en.wikipedia.org/wiki/Implicit_directional_marks
  String get _directionalityMark {
    if (isRtl) {
      switch (_languageSubtag) {
        case LanguageCodesIso639_1.arabic:
          return Unicode.ALM;
        default:
          return Unicode.RLM;
      }
    } else {
      return Unicode.LRM;
    }
  }
}
