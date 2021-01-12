import 'package:flutter/material.dart';

// This widget should be added on top of Scaffolds with:
// - `resizeToAvoidBottomInset` set to false,
// - a vertically scrollable body.
// It will prevent the body from scrolling when a user swipe from bottom to use Android Q style navigation gestures.
class BottomGestureAreaProtector extends StatelessWidget {
  // as of Flutter v1.22.5, `systemGestureInsets` from `MediaQuery` mistakenly reports no bottom inset,
  // so we use an empirical measurement instead
  static const double systemGestureInsetsBottom = 32;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: systemGestureInsetsBottom,
      child: AbsorbPointer(),
    );
  }
}

class GestureAreaProtectorStack extends StatelessWidget {
  final Widget child;

  const GestureAreaProtectorStack({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BottomGestureAreaProtector(),
      ],
    );
  }
}
