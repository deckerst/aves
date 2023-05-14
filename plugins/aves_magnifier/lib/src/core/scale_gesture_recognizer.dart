import 'dart:math';

import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_magnifier/src/pan/edge_hit_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class MagnifierGestureRecognizer extends ScaleGestureRecognizer {
  final MagnifierGestureDetectorScope scope;
  final ValueNotifier<TapDownDetails?> doubleTapDetails;

  EdgeHitDetector? hitDetector;

  MagnifierGestureRecognizer({
    super.debugOwner,
    required this.scope,
    required this.doubleTapDetails,
  });

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
    if (scope.axis.isNotEmpty) {
      var didChangeConfiguration = false;
      final pointer = event.pointer;
      if (event is PointerMoveEvent) {
        if (!event.synthesized) {
          _pointerLocations[pointer] = event.position;
        }
      } else if (event is PointerDownEvent) {
        _pointerLocations[pointer] = event.position;
        didChangeConfiguration = true;
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        _pointerLocations.remove(pointer);
        didChangeConfiguration = true;
      }

      _updateDistances();

      if (didChangeConfiguration) {
        // cf super._reconfigure
        _initialFocalPoint = _currentFocalPoint;
        _initialSpan = _currentSpan;
      }

      if (event is PointerMoveEvent) {
        if (_areMultiPointers()) {
          acceptGesture(pointer);
        } else if (_isPriorityGesture() && _isOverSlop(event.kind)) {
          acceptGesture(pointer);
        } else {
          final axis = scope.axis;
          final isPriorityMove = (axis.contains(Axis.horizontal) && _canPanX()) || (axis.contains(Axis.vertical) && _canPanY());
          if (isPriorityMove && _isOverSlop(event.kind)) {
            acceptGesture(pointer);
          }
        }
      }
    }
    super.handleEvent(event);
  }

  @override
  void resolve(GestureDisposition disposition) {
    switch (disposition) {
      case GestureDisposition.accepted:
        // do not let super `ScaleGestureRecognizer` accept gestures
        // when it should yield to other recognizers
        final canAccept = _areMultiPointers() || _isPriorityGesture() || _canPanX() || _canPanY();
        super.resolve(canAccept ? GestureDisposition.accepted : GestureDisposition.rejected);
      case GestureDisposition.rejected:
        super.resolve(disposition);
    }
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

  Offset get move => _initialFocalPoint! - _currentFocalPoint!;

  // when there are multiple pointers, we always accept the gesture to scale
  // as this is not competing with single taps or other drag gestures
  bool _areMultiPointers() => _pointerLocations.keys.length >= 2;

  bool _isPriorityGesture() {
    // e.g. vertical drag to adjust brightness instead of panning
    if (scope.acceptPointerEvent?.call(move) ?? false) return true;

    // e.g. double tap & drag for one finger zoom
    if (doubleTapDetails.value != null) return true;

    return false;
  }

  bool _canPanX() => hitDetector != null && hitDetector!.shouldMoveX(move, scope.escapeByFling) && isXPan(move);

  bool _canPanY() => hitDetector != null && hitDetector!.shouldMoveY(move, scope.escapeByFling) && isYPan(move);

  bool _isOverSlop(PointerDeviceKind kind) {
    final spanDelta = (_currentSpan! - _initialSpan!).abs();
    final focalPointDelta = move.distance;
    // warning: do not compare `focalPointDelta` to `kPanSlop`
    // `ScaleGestureRecognizer` uses `kPanSlop` (or platform settings, cf gestures/events.dart `computePanSlop`),
    // but `HorizontalDragGestureRecognizer` uses `kTouchSlop` (or platform settings, cf gestures/events.dart `computeHitSlop`)
    // and the magnifier recognizer may compete with the `HorizontalDragGestureRecognizer` from a containing `PageView`
    // setting `touchSlopFactor` to 2 restores default `ScaleGestureRecognizer` behaviour as `kPanSlop = kTouchSlop * 2.0`
    // setting `touchSlopFactor` in [0, 1] will allow this recognizer to accept the gesture before the one from `PageView`
    return spanDelta > computeScaleSlop(kind) || focalPointDelta > computeHitSlop(kind, gestureSettings) * scope.touchSlopFactor;
  }

  static bool isXPan(Offset move) {
    // the gesture direction angle is in ]-pi, pi], cf `Offset` doc for details
    final d = move.direction;
    return (-pi / 4 < d && d < pi / 4) || (3 / 4 * pi < d && d <= pi) || (-pi < d && d < -3 / 4 * pi);
  }

  static bool isYPan(Offset move) {
    // the gesture direction angle is in ]-pi, pi], cf `Offset` doc for details
    final d = move.direction;
    return (pi / 4 < d && d < 3 / 4 * pi) || (-3 / 4 * pi < d && d < -pi / 4);
  }
}
