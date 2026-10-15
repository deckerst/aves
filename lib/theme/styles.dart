import 'package:aves/l10ngen/app_localizations_en.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:flutter/widgets.dart';

class AStyles {
  static TextStyle _baseTitleStyle(KnownLocale? locale) {
    final supportSmallCaps = locale?.supportSmallCaps ?? true;
    final supportLetterSpacing = locale?.supportLetterSpacing ?? true;
    return TextStyle(
      fontWeight: supportSmallCaps ? .w300 : .normal,
      letterSpacing: supportSmallCaps && supportLetterSpacing ? 1 : 0,
      fontFeatures: supportSmallCaps ? const [FontFeature.enable('smcp')] : [],
    );
  }

  static final String _originalAppName = AppLocalizationsEn().appName;

  static TextStyle appNameStyle(BuildContext context, String appName) {
    final locale = appName != _originalAppName ? context.knownLocale : KnownLocale.english;
    return _baseTitleStyle(locale);
  }

  static TextStyle pageTitleTextStyle(KnownLocale locale) {
    return _baseTitleStyle(locale).copyWith(
      fontSize: 20,
      fontWeight: .normal,
    );
  }

  static TextStyle sectionTitleStyle(KnownLocale? locale) {
    return _baseTitleStyle(locale).copyWith(
      fontSize: 20,
    );
  }

  static const embossShadows = [
    Shadow(
      color: Color(0xFF000000),
      offset: Offset(0.5, 1.0),
    ),
  ];
}
