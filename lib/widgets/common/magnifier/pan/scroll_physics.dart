import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

// `PageView` contains a `Scrollable` which sets up a `HorizontalDragGestureRecognizer`
// this recognizer will win in the gesture arena when the drag distance reaches `kTouchSlop`
// we cannot change that, but we can prevent the scrollable from panning until this threshold is reached
// and let other recognizers accept the gesture instead
class MagnifierScrollerPhysics extends ScrollPhysics {
  const MagnifierScrollerPhysics({
    this.touchSlopFactor = 1,
    ScrollPhysics parent,
  }) : super(parent: parent);

  // in [0, 1]
  // 0: most reactive but will not let Magnifier recognizers accept gestures
  // 1: less reactive but gives the most leeway to Magnifier recognizers
  final double touchSlopFactor;

  @override
  MagnifierScrollerPhysics applyTo(ScrollPhysics ancestor) {
    return MagnifierScrollerPhysics(
      touchSlopFactor: touchSlopFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double get dragStartDistanceMotionThreshold => kTouchSlop * touchSlopFactor;
}
