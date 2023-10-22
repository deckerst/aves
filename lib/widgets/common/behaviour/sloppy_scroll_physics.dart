import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

// TODO TLAD merge with `MagnifierScrollerPhysics`
class SloppyScrollPhysics extends ScrollPhysics {
  final DeviceGestureSettings? gestureSettings;

  // in [0, 1]
  // 0: most reactive but will not let Magnifier recognizers accept gestures
  // 1: less reactive but gives the most leeway to Magnifier recognizers
  final double touchSlopFactor;

  const SloppyScrollPhysics({
    required this.gestureSettings,
    this.touchSlopFactor = 1,
    super.parent,
  });

  @override
  SloppyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SloppyScrollPhysics(
      gestureSettings: gestureSettings,
      touchSlopFactor: touchSlopFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double get dragStartDistanceMotionThreshold => (gestureSettings?.touchSlop ?? kTouchSlop) * touchSlopFactor;
}
