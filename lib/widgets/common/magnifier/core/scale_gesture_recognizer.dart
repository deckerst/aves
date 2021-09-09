import 'dart:math';

import 'package:aves/widgets/common/magnifier/pan/corner_hit_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class MagnifierGestureRecognizer extends ScaleGestureRecognizer {
  final CornerHitDetector hitDetector;
  final List<Axis> validateAxis;
  final double touchSlopFactor;
  final ValueNotifier<TapDownDetails?> doubleTapDetails;

  MagnifierGestureRecognizer({
    Object? debugOwner,
    required this.hitDetector,
    required this.validateAxis,
    this.touchSlopFactor = 2,
    required this.doubleTapDetails,
  }) : super(debugOwner: debugOwner);

  Map<int, Offset> _pointerLocations = <int, Offset>{};

  Offset? _initialFocalPoint;
  Offset? _currentFocalPoint;
  double? _initialSpan;
  double? _currentSpan;

  bool ready = true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (ready) {
      ready = false;
      _initialSpan = 0.0;
      _currentSpan = 0.0;
      _pointerLocations = <int, Offset>{};
    }
    super.addAllowedPointer(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    ready = true;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (validateAxis.isNotEmpty) {
      var didChangeConfiguration = false;
      if (event is PointerMoveEvent) {
        if (!event.synthesized) {
          _pointerLocations[event.pointer] = event.position;
        }
      } else if (event is PointerDownEvent) {
        _pointerLocations[event.pointer] = event.position;
        didChangeConfiguration = true;
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        _pointerLocations.remove(event.pointer);
        didChangeConfiguration = true;
      }

      _updateDistances();

      if (didChangeConfiguration) {
        // cf super._reconfigure
        _initialFocalPoint = _currentFocalPoint;
        _initialSpan = _currentSpan;
      }

      _decideIfWeAcceptEvent(event);
    }
    super.handleEvent(event);
  }

  void _updateDistances() {
    // cf super._update
    final count = _pointerLocations.keys.length;

    // Compute the focal point
    var focalPoint = Offset.zero;
    for (final pointer in _pointerLocations.keys) {
      focalPoint += _pointerLocations[pointer]!;
    }
    _currentFocalPoint = count > 0 ? focalPoint / count.toDouble() : Offset.zero;

    // Span is the average deviation from focal point. Horizontal and vertical
    // spans are the average deviations from the focal point's horizontal and
    // vertical coordinates, respectively.
    var totalDeviation = 0.0;
    for (final pointer in _pointerLocations.keys) {
      totalDeviation += (_currentFocalPoint! - _pointerLocations[pointer]!).distance;
    }
    _currentSpan = count > 0 ? totalDeviation / count : 0.0;
  }

  void _decideIfWeAcceptEvent(PointerEvent event) {
    if (event is! PointerMoveEvent) return;

    if (_pointerLocations.keys.length >= 2) {
      // when there are multiple pointers, we always accept the gesture to scale
      // as this is not competing with single taps or other drag gestures
      acceptGesture(event.pointer);
      return;
    }

    final move = _initialFocalPoint! - _currentFocalPoint!;
    var shouldMove = false;
    if (validateAxis.length == 2) {
      // the image is the descendant of gesture detector(s) handling drag in both directions
      final shouldMoveX = validateAxis.contains(Axis.horizontal) && hitDetector.shouldMoveX(move);
      final shouldMoveY = validateAxis.contains(Axis.vertical) && hitDetector.shouldMoveY(move);
      if (shouldMoveX == shouldMoveY) {
        // consistently can/cannot pan the image in both direction the same way
        shouldMove = shouldMoveX;
      } else {
        // can pan the image in one direction, but should yield to an ascendant gesture detector in the other one
        final d = move.direction;
        // the gesture direction angle is in ]-pi, pi], cf `Offset` doc for details
        final xPan = (-pi / 4 < d && d < pi / 4) || (3 / 4 * pi < d && d <= pi) || (-pi < d && d < -3 / 4 * pi);
        final yPan = (pi / 4 < d && d < 3 / 4 * pi) || (-3 / 4 * pi < d && d < -pi / 4);
        shouldMove = (xPan && shouldMoveX) || (yPan && shouldMoveY);
      }
    } else {
      // the image is the descendant of a gesture detector handling drag in one direction
      shouldMove = validateAxis.contains(Axis.vertical) ? hitDetector.shouldMoveY(move) : hitDetector.shouldMoveX(move);
    }

    final doubleTap = doubleTapDetails.value != null;
    if (shouldMove || doubleTap) {
      final spanDelta = (_currentSpan! - _initialSpan!).abs();
      final focalPointDelta = (_currentFocalPoint! - _initialFocalPoint!).distance;
      // warning: do not compare `focalPointDelta` to `kPanSlop`
      // `ScaleGestureRecognizer` uses `kPanSlop`, but `HorizontalDragGestureRecognizer` uses `kTouchSlop`
      // and the magnifier recognizer may compete with the `HorizontalDragGestureRecognizer` from a containing `PageView`
      // setting `touchSlopFactor` to 2 restores default `ScaleGestureRecognizer` behaviour as `kPanSlop = kTouchSlop * 2.0`
      // setting `touchSlopFactor` in [0, 1] will allow this recognizer to accept the gesture before the one from `PageView`
      if (spanDelta > kScaleSlop || focalPointDelta > kTouchSlop * touchSlopFactor) {
        acceptGesture(event.pointer);
      }
    }
  }
}
