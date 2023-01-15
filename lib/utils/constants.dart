import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Constants {
  static const separator = ' • ';

  // `Color(0x00FFFFFF)` is different from `Color(0x00000000)` (or `Colors.transparent`)
  // when used in gradients or lerping to it
  static const transparentWhite = Color(0x00FFFFFF);
  static const transparentBlack = Colors.transparent;

  // as of Flutter v2.8.0, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrutStyle = StrutStyle(height: 1.3);

  static const double colorPickerRadius = 16;

  static const knownTitleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static TextStyle unknownTitleTextStyle = knownTitleTextStyle;

  static void updateStylesForLocale(Locale locale) {
    final smcp = locale.languageCode != 'el';
    unknownTitleTextStyle = smcp ? knownTitleTextStyle : knownTitleTextStyle.copyWith(fontFeatures: []);
  }

  static const embossShadows = [
    Shadow(
      color: Colors.black,
      offset: Offset(0.5, 1.0),
    )
  ];

  static const boraBoraGradientColors = [
    Color(0xff2bc0e4),
    Color(0xffeaecc6),
  ];

  // Bidi fun, cf https://www.unicode.org/reports/tr9/
  // First Strong Isolate
  static const fsi = '\u2068';

  // Pop Directional Isolate
  static const pdi = '\u2069';

  static const zwsp = '\u200B';

  static const overlayUnknown = '—'; // em dash

  static final pointNemo = LatLng(-48.876667, -123.393333);

  static final wonders = [
    LatLng(29.979167, 31.134167),
    LatLng(36.451000, 28.223615),
    LatLng(32.5355, 44.4275),
    LatLng(31.213889, 29.885556),
    LatLng(37.0379, 27.4241),
    LatLng(37.637861, 21.63),
    LatLng(37.949722, 27.363889),
  ];

  static const int infoGroupMaxValueLength = 140;

  static const String avesGithub = 'https://github.com/deckerst/aves';
}
