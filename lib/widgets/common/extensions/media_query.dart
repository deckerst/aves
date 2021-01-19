import 'dart:math';

import 'package:flutter/widgets.dart';

extension ExtraMediaQueryData on MediaQueryData {
  /*
  examples of MediaQuery props in practice, as of Flutter v1.22.5

  S20, Android 11, portrait, notch top, button nav bar bottom
  padding           EdgeInsets(0.0, 26.0, 0.0, 48.0)
  viewPadding       EdgeInsets(0.0, 26.0, 0.0, 48.0)
  viewInsets        EdgeInsets.zero

  S20, Android 11, landscape, notch left, button nav bar right
  padding           EdgeInsets(26.0, 24.0, 0.0, 0.0)
  viewPadding       EdgeInsets(26.0, 24.0, 0.0, 0.0)
  viewInsets        EdgeInsets.zero

  S10e, Android 10, portrait, notch top, button nav bar bottom
  padding           EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewInsets        EdgeInsets(0.0, 0.0, 0.0, 48.0)

  S10e, Android 10, portrait, notch top, gesture nav bar bottom
  padding           EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewInsets        EdgeInsets(0.0, 0.0, 0.0, 15.0)

  S10e, Android 10, landscape, notch left, button nav bar right
  padding           EdgeInsets(38.7, 24.0, 0.0, 0.0)
  viewPadding       EdgeInsets(38.7, 24.0, 0.0, 0.0)
  viewInsets        EdgeInsets.zero

  S7, portrait/landscape, no notch, no nav bar
  padding           EdgeInsets(0.0, 24.0, 0.0, 0.0)
  viewPadding       EdgeInsets(0.0, 24.0, 0.0, 0.0)
  viewInsets        EdgeInsets.zero
   */

  double get effectiveBottomPadding => max(viewPadding.bottom, viewInsets.bottom);
}
