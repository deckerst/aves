import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class SloppyScrollPhysics extends ScrollPhysics {
  const SloppyScrollPhysics({
    this.touchSlopFactor = 1,
    ScrollPhysics parent,
  }) : super(parent: parent);

  // in [0, 1]
  // 0: most reactive but will not let other recognizers accept gestures
  // 1: less reactive but gives the most leeway to other recognizers
  final double touchSlopFactor;

  @override
  SloppyScrollPhysics applyTo(ScrollPhysics ancestor) {
    return SloppyScrollPhysics(
      touchSlopFactor: touchSlopFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double get dragStartDistanceMotionThreshold => kTouchSlop * touchSlopFactor;
}
