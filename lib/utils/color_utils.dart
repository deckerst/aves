import 'package:flutter/material.dart';

Color stringToColor(String string, {double saturation = .8, double lightness = .6}) {
  final hash = string.codeUnits.fold(0, (prev, el) => prev = el + ((prev << 5) - prev));
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}
