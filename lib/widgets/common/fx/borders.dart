import 'dart:ui';

import 'package:flutter/material.dart';

class AvesBorder {
  static const borderColor = Colors.white30;

  // directly uses `devicePixelRatio` as it never changes, to avoid visiting ancestors via `MediaQuery`

  // 1 device pixel for straight lines is fine
  static double get straightBorderWidth => 1 / window.devicePixelRatio;

  // 1 device pixel for curves is too thin
  static double get curvedBorderWidth => window.devicePixelRatio > 2 ? 0.5 : 1.0;

  static BorderSide get straightSide => BorderSide(
        color: borderColor,
        width: straightBorderWidth,
      );

  static BorderSide get curvedSide => BorderSide(
        color: borderColor,
        width: curvedBorderWidth,
      );

  static Border get border => Border.fromBorderSide(curvedSide);
}
