import 'dart:ui';

import 'package:flutter/material.dart';

class AvesBorder {
  static Color _borderColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black26;

  // directly uses `devicePixelRatio` as it never changes, to avoid visiting ancestors via `MediaQuery`

  // 1 device pixel for straight lines is fine
  static double get straightBorderWidth => 1 / window.devicePixelRatio;

  // 1 device pixel for curves is too thin
  static double get curvedBorderWidth => window.devicePixelRatio > 2 ? 0.5 : 1.0;

  static BorderSide straightSide(BuildContext context, {double? width}) => BorderSide(
        color: _borderColor(context),
        width: width ?? straightBorderWidth,
      );

  static BorderSide curvedSide(BuildContext context, {double? width}) => BorderSide(
        color: _borderColor(context),
        width: width ?? curvedBorderWidth,
      );

  static Border border(BuildContext context, {double? width}) => Border.fromBorderSide(curvedSide(context, width: width));
}
