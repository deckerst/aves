import 'package:flutter/painting.dart';

class AStyles {
  static const knownTitleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static TextStyle unknownTitleText = knownTitleText;

  static void updateStylesForLocale(Locale locale) {
    final smcp = locale.languageCode != 'el';
    unknownTitleText = smcp ? knownTitleText : knownTitleText.copyWith(fontFeatures: []);
  }

  static const embossShadows = [
    Shadow(
      color: Color(0xFF000000),
      offset: Offset(0.5, 1.0),
    )
  ];
}
