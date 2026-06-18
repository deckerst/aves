import 'dart:ui';

import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class SlowMotionRange {
  final double start, end; // in [0, 1]

  SlowMotionRange({
    required double start,
    required double end,
  }) : start = start.clamp(0, 1),
       end = end.clamp(0, 1);

  SlowMotionRange sanitize() {
    if (start > end) {
      return SlowMotionRange(start: end, end: start);
    }
    return SlowMotionRange(start: start, end: end);
  }
}

mixin SlowMotionMixin on Disposer {
  int slowMotionFactor = 1;
  ValueNotifier<SlowMotionRange> slowMotionRangeNotifier = ValueNotifier(SlowMotionRange(start: .25, end: .75));

  bool get isSlowMotion => slowMotionFactor != 1;

  static const double fallbackPlaybackFps = 30;
  static const int _approachDurationMillis = 300;

  @override
  void dispose() {
    slowMotionRangeNotifier.dispose();
    super.dispose();
  }

  void setSlowMotionStart(double start) => _setSlowMotion(SlowMotionRange(start: start, end: slowMotionRangeNotifier.value.end));

  void setSlowMotionEnd(double end) => _setSlowMotion(SlowMotionRange(start: slowMotionRangeNotifier.value.start, end: end));

  void _setSlowMotion(SlowMotionRange v) => slowMotionRangeNotifier.value = v.sanitize();

  double getSlowMotionTargetSpeed({required int currentPosition, required int duration}) {
    double targetSpeed = 1.0;

    if (duration == 0) return targetSpeed;

    final range = slowMotionRangeNotifier.value;
    var startPosition = range.start * duration;
    var endPosition = range.end * duration;

    // no approach when range is on video edges
    if (startPosition == 0) {
      startPosition -= _approachDurationMillis;
    }
    if (endPosition == duration) {
      endPosition += _approachDurationMillis;
    }

    final startDelta = currentPosition - startPosition;
    final endDelta = currentPosition - endPosition;

    double t = startDelta.abs() < endDelta.abs() ? startDelta : -endDelta;
    t = ((t + _approachDurationMillis) / (2 * _approachDurationMillis)).clamp(0, 1);

    targetSpeed = lerpDouble(1, 1 / slowMotionFactor, roundToPrecision(t, decimals: 1)) ?? targetSpeed;
    return targetSpeed;
  }
}
