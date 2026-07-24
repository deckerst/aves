import 'package:aves/l10n/l10n.dart';
import 'package:aves/ref/languages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension ExtraContext on BuildContext {
  String? get currentRouteName => ModalRoute.of(this)?.settings.name;

  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // returns `xx_YY`, but case and separator are not guaranteed (cf `Intl.canonicalizedLocale()`)
  String get localeName => l10n.localeName;

  bool get isArabic => localeName.startsWith(LanguageCodesIso639_1.arabic);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  String applyDirectionality(String text) => '$_directionalityMark$text';

  String get _directionalityMark {
    if (isRtl) {
      return isArabic ? Unicode.ALM : Unicode.RLM;
    } else {
      return Unicode.LRM;
    }
  }
}
