import 'package:aves/ref/locale/iso639_1.dart';
import 'package:flutter/painting.dart';

class AStyles {
  static const knownTitleText = TextStyle(
    fontSize: 20,
    fontWeight: .w300,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static TextStyle unknownTitleText = knownTitleText;

  static void updateStylesForLocale(String languageSubtag) {
    final smcp = languageSubtag != LanguageCodesIso639_1.greek;
    unknownTitleText = smcp ? knownTitleText : knownTitleText.copyWith(fontFeatures: []);
  }

  static const embossShadows = [
    Shadow(
      color: Color(0xFF000000),
      offset: Offset(0.5, 1.0),
    ),
  ];
}
