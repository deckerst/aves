import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesCircleBorder {
  static const borderColor = Colors.white30;

  static double _borderWidth(BuildContext context) => context.read<MediaQueryData>().devicePixelRatio > 2 ? 0.5 : 1.0;

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
