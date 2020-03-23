import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Constants {
  // as of Flutter v1.11.0, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrutStyle = StrutStyle(height: 1.3);

  static const svgBackground = Colors.white;
  static const svgColorFilter = ColorFilter.mode(svgBackground, BlendMode.dstOver);
}
