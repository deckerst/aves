import 'dart:ui';

import 'package:flutter/material.dart';

class AvesBorder {
  static const borderColor = Colors.white30;

  // directly uses `devicePixelRatio` as it never changes, to avoid visiting ancestors via `MediaQuery`
  static double get borderWidth => window.devicePixelRatio > 2 ? 0.5 : 1.0;

  static BorderSide get side => BorderSide(
        color: borderColor,
        width: borderWidth,
      );

  static Border get border => Border.fromBorderSide(side);
}
