import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

// `PageView` contains a `Scrollable` which sets up a `HorizontalDragGestureRecognizer`.
// This recognizer will win in the gesture arena when the drag distance reaches
// `kTouchSlop` (or platform settings, cf gestures/events.dart `computeHitSlop`).
// We cannot change that, but we can prevent the scrollable from panning until this threshold is reached
// and let other recognizers accept the gesture instead.
class MagnifierScrollerPhysics extends ScrollPhysics {
  final DeviceGestureSettings? gestureSettings;

  // in [0, 1]
  // 0: most reactive but will not let Magnifier recognizers accept gestures
  // 1: less reactive but gives the most leeway to Magnifier recognizers
  final double touchSlopFactor;

  const MagnifierScrollerPhysics({
    required this.gestureSettings,
    this.touchSlopFactor = 1,
    super.parent,
  });

  @override
  MagnifierScrollerPhysics applyTo(ScrollPhysics? ancestor) {
    return MagnifierScrollerPhysics(
      gestureSettings: gestureSettings,
      touchSlopFactor: touchSlopFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double get dragStartDistanceMotionThreshold => (gestureSettings?.touchSlop ?? kTouchSlop) * touchSlopFactor;
}
