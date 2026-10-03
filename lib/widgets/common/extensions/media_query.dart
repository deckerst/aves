import 'dart:math';

import 'package:flutter/widgets.dart';

extension ExtraMediaQueryData on MediaQueryData {
  /*
  examples of MediaQuery props in practice

  -- Flutter v1.22.5

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

  -- Flutter v2.2.1

  S10e, Android 11, portrait, notch top, button nav bar bottom, keyboard off
  padding           EdgeInsets(0.0, 39.0, 0.0, 48.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 48.0)
  viewInsets        EdgeInsets.zero

  S10e, Android 11, portrait, notch top, button nav bar bottom, keyboard on
  padding           EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 48.0)
  viewInsets        EdgeInsets(0.0, 0.0, 0.0, 338.0)

  S10e, Android 11, portrait, notch top, gesture nav bar bottom, keyboard off
  padding           EdgeInsets(0.0, 39.0, 0.0, 15.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 15.0)
  viewInsets        EdgeInsets.zero

  S10e, Android 11, portrait, notch top, gesture nav bar bottom, keyboard on
  padding           EdgeInsets(0.0, 39.0, 0.0, 0.0)
  viewPadding       EdgeInsets(0.0, 39.0, 0.0, 15.0)
  viewInsets        EdgeInsets(0.0, 0.0, 0.0, 338.0)
   */

  double get safeBottomPadding => <double>{
    viewPadding.bottom,
    viewInsets.bottom,
    systemGestureInsets.bottom,
    bottomDisplayCornerRadius,
  }.fold(0, max);

  double get bottomDisplayCornerRadius {
    final r = displayCornerRadii;
    if (r == null) return 0;
    final bl = r.bottomLeft;
    final br = r.bottomRight;
    return [bl.x, bl.y, br.x, br.y].fold(0, max);
  }

  MediaQueryData removeCutoutInsets(EdgeInsets cutoutInsets) {
    return copyWith(
      padding: EdgeInsets.only(
        left: max(0.0, padding.left - cutoutInsets.left),
        top: max(0.0, padding.top - cutoutInsets.top),
        right: max(0.0, padding.right - cutoutInsets.right),
        bottom: max(0.0, padding.bottom - cutoutInsets.bottom),
      ),
      viewPadding: EdgeInsets.only(
        left: max(0.0, viewPadding.left - cutoutInsets.left),
        top: max(0.0, viewPadding.top - cutoutInsets.top),
        right: max(0.0, viewPadding.right - cutoutInsets.right),
        bottom: max(0.0, viewPadding.bottom - cutoutInsets.bottom),
      ),
    );
  }
}
