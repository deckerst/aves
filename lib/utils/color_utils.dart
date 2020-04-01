import 'package:flutter/material.dart';

final Map<String, Color> _stringColors = {};

Color stringToColor(String string, {double saturation = .8, double lightness = .6}) {
  var color = _stringColors[string];
  if (color == null) {
    final hash = string.codeUnits.fold(0, (prev, el) => prev = el + ((prev << 5) - prev));
    final hue = (hash % 360).toDouble();
    color = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    _stringColors[string] = color;
  }
  return color;
}
