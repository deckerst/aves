import 'package:flutter/material.dart';

class AvesCircleBorder {
  static const borderColor = Colors.white30;

  static double _borderWidth(BuildContext context) => MediaQuery.of(context).devicePixelRatio > 2 ? 0.5 : 1.0;

  static Border build(BuildContext context) {
    return Border.fromBorderSide(buildSide(context));
  }

  static BorderSide buildSide(BuildContext context) {
    return BorderSide(
      color: borderColor,
      width: _borderWidth(context),
    );
  }
}
