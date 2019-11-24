import 'package:flutter/painting.dart';

class Constants {
  // as of Flutter v1.11.0, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrutStyle = StrutStyle(height: 1.3);
}