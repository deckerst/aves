import 'package:flutter/material.dart';

class AvesCircleBorder {
  static BoxBorder build(BuildContext context) {
    final subPixel = MediaQuery.of(context).devicePixelRatio > 2;
    return Border.all(
      color: Colors.white30,
      width: subPixel ? 0.5 : 1.0,
    );
  }
}
