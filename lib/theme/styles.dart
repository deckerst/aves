import 'dart:ui';

import 'package:flutter/painting.dart';

class AStyles {
  // as of Flutter v2.8.0, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrut = StrutStyle(height: 1.3);

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
