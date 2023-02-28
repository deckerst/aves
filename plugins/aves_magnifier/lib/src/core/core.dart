import 'dart:math';

import 'package:aves_magnifier/src/controller/controller.dart';
import 'package:aves_magnifier/src/controller/controller_delegate.dart';
import 'package:aves_magnifier/src/controller/state.dart';
import 'package:aves_magnifier/src/core/gesture_detector.dart';
import 'package:aves_magnifier/src/magnifier.dart';
import 'package:aves_magnifier/src/pan/edge_hit_detector.dart';
import 'package:aves_magnifier/src/scale/scale_boundaries.dart';
import 'package:aves_magnifier/src/scale/state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to the controller state and mounts the entire Layout
class MagnifierCore extends StatefulWidget {
  final AvesMagnifierController controller;
  final ScaleStateCycle scaleStateCycle;
  final bool applyScale;
  final double panInertia;
  final MagnifierGestureScaleStartCallback? onScaleStart;
  final MagnifierGestureScaleUpdateCallback? onScaleUpdate;
  final MagnifierGestureScaleEndCallback? onScaleEnd;
  final MagnifierGestureFlingCallback? onFling;
  final MagnifierTapCallback? onTap;
  final MagnifierDoubleTapCallback? onDoubleTap;
  final Widget child;

  const MagnifierCore({
    super.key,
    required this.controller,
    required this.scaleStateCycle,
    required this.applyScale,
    this.panInertia = .2,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onFling,
    this.onTap,
    this.onDoubleTap,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _MagnifierCoreState();
}

class _MagnifierCoreState extends State<MagnifierCore> with TickerProviderStateMixin, AvesMagnifierControllerDelegate, EdgeHitDetector {
  Offset? _startFocalPoint, _lastViewportFocalPosition;
  double? _startScale, _quickScaleLastY, _quickScaleLastDistance;
  late bool _dropped, _doubleTap, _quickScaleMoved;
  DateTime _lastScaleGestureDate = DateTime.now();

  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  late AnimationController _positionAnimationController;
  late Animation<Offset> _positionAnimation;

  ScaleBoundaries? cachedScaleBoundaries;

  static const _flingPointerKind = PointerDeviceKind.unknown;

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation)
      ..addStatusListener(onAnimationStatus);
    _positionAnimationController = AnimationController(vsync: this)..addListener(handlePositionAnimate);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant MagnifierCore oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    super.dispose();
  }

  void _registerWidget(MagnifierCore widget) {
    registerDelegate(widget);
    cachedScaleBoundaries = widget.controller.scaleBoundaries;
    setScaleStateUpdateAnimation(animateOnScaleStateUpdate);
  }

  void _unregisterWidget(MagnifierCore oldWidget) {
    unregisterDelegate(oldWidget);
    cachedScaleBoundaries = null;
  }

  void handleScaleAnimation() {
    setScale(_scaleAnimation.value, ChangeSource.animation);
  }

  void handlePositionAnimate() {
    controller.update(position: _positionAnimation.value, source: ChangeSource.animation);
  }

  Stopwatch? _scaleStopwatch;
  VelocityTracker? _velocityTracker;
  var _mayFlingLTRB = const Tuple4(false, false, false, false);

  void onScaleStart(ScaleStartDetails details, bool doubleTap) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    widget.onScaleStart?.call(details, doubleTap, boundaries);

    _scaleStopwatch = Stopwatch()..start();
    _velocityTracker = VelocityTracker.withKind(_flingPointerKind);
    _mayFlingLTRB = const Tuple4(true, true, true, true);
    _updateMayFling();

    _startScale = scale;
    _startFocalPoint = details.localFocalPoint;
    _lastViewportFocalPosition = _startFocalPoint;
    _dropped = false;
    _doubleTap = doubleTap;
    _quickScaleLastDistance = null;
    _quickScaleLastY = _startFocalPoint!.dy;
    _quickScaleMoved = false;

    _scaleAnimationController.stop();
    _positionAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    _dropped |= widget.onScaleUpdate?.call(details) ?? false;
    if (_dropped) return;

    final elapsed = _scaleStopwatch?.elapsed;
    if (elapsed != null) {
      _velocityTracker?.addPosition(elapsed, details.focalPoint);
    }
    _updateMayFling();

    double newScale;
    if (_doubleTap) {
      // quick scale, aka one finger zoom
      // magic numbers from `davemorrissey/subsampling-scale-image-view`
      final focalPointY = details.localFocalPoint.dy;
      final distance = (focalPointY - _startFocalPoint!.dy).abs() * 2 + 20;
      _quickScaleLastDistance ??= distance;
      final spanDiff = (1 - (distance / _quickScaleLastDistance!)).abs() * .5;
      _quickScaleMoved |= spanDiff > .03;
      final factor = _quickScaleMoved ? (focalPointY > _quickScaleLastY! ? (1 + spanDiff) : (1 - spanDiff)) : 1;
      _quickScaleLastDistance = distance;
      _quickScaleLastY = focalPointY;
      newScale = scale! * factor;
    } else {
      newScale = _startScale! * details.scale;
    }
    final scaleFocalPoint = _doubleTap ? _startFocalPoint! : details.localFocalPoint;

    final panPositionDelta = scaleFocalPoint - _lastViewportFocalPosition!;
    final scalePositionDelta = boundaries.viewportToStatePosition(controller, scaleFocalPoint) * (scale! / newScale - 1);
    final newPosition = position + panPositionDelta + scalePositionDelta;

    updateScaleStateFromNewScale(newScale, ChangeSource.gesture);
    updateMultiple(
      scale: max(0, newScale),
      position: newPosition,
      source: ChangeSource.gesture,
    );

    _lastViewportFocalPosition = scaleFocalPoint;
  }

  void onScaleEnd(ScaleEndDetails details) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    widget.onScaleEnd?.call(details);

    _updateMayFling();
    final estimate = _velocityTracker?.getVelocityEstimate();
    final onFling = widget.onFling;
    if (estimate != null && onFling != null) {
      if (_isFlingGesture(estimate, _flingPointerKind, Axis.horizontal)) {
        final left = _mayFlingLTRB.item1;
        final right = _mayFlingLTRB.item3;
        if (left ^ right) {
          if (left) {
            onFling(AxisDirection.left);
          } else if (right) {
            onFling(AxisDirection.right);
          }
        }
      } else if (_isFlingGesture(estimate, _flingPointerKind, Axis.vertical)) {
        final up = _mayFlingLTRB.item2;
        final down = _mayFlingLTRB.item4;
        if (up ^ down) {
          if (up) {
            onFling(AxisDirection.up);
          } else if (down) {
            onFling(AxisDirection.down);
          }
        }
      }
    }

    final _position = controller.position;
    final _scale = controller.scale!;
    final maxScale = boundaries.maxScale;
    final minScale = boundaries.minScale;

    // animate back to min/max scale if gesture yielded a scale exceeding them
    if (_scale > maxScale || _scale < minScale) {
      final newScale = _scale.clamp(minScale, maxScale);
      final newPosition = clampPosition(position: _position * newScale / _scale, scale: newScale);
      animateScale(_scale, newScale);
      animatePosition(_position, newPosition);
      return;
    }

    // The gesture recognizer triggers a new `onScaleStart` every time a pointer/finger is added or removed.
    // Following a pinch-to-zoom gesture, a new panning gesture may start if the user does not lift both fingers at the same time,
    // so we dismiss such panning gestures when it looks like it followed a scaling gesture.
    final isPanning = _scale == _startScale && (DateTime.now().difference(_lastScaleGestureDate)).inMilliseconds > 100;

    // animate position only when panning without scaling
    if (isPanning) {
      final pps = details.velocity.pixelsPerSecond;
      if (pps != Offset.zero) {
        final newPosition = clampPosition(position: _position + pps * widget.panInertia);
        if (_position != newPosition) {
          final tween = Tween<Offset>(begin: _position, end: newPosition);
          const curve = Curves.easeOutCubic;
          _positionAnimation = tween.animate(CurvedAnimation(parent: _positionAnimationController, curve: curve));
          _positionAnimationController
            ..duration = _getAnimationDurationForVelocity(curve: curve, tween: tween, targetPixelPerSecond: pps)
            ..forward(from: 0.0);
        }
      }
    }

    if (_scale != _startScale) {
      _lastScaleGestureDate = DateTime.now();
    }
  }

  void _updateMayFling() {
    final xHit = getXEdgeHit();
    final yHit = getYEdgeHit();
    _mayFlingLTRB = Tuple4(
      _mayFlingLTRB.item1 && xHit.hasHitMin,
      _mayFlingLTRB.item2 && yHit.hasHitMin,
      _mayFlingLTRB.item3 && xHit.hasHitMax,
      _mayFlingLTRB.item4 && yHit.hasHitMax,
    );
  }

  bool _isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind, Axis axis) {
    final gestureSettings = context.read<MediaQueryData>().gestureSettings;
    const minVelocity = kMinFlingVelocity;
    final minDistance = computeHitSlop(kind, gestureSettings);

    final pps = estimate.pixelsPerSecond;
    final offset = estimate.offset;
    if (axis == Axis.horizontal) {
      return pps.dx.abs() > minVelocity && offset.dx.abs() > minDistance;
    } else {
      return pps.dy.abs() > minVelocity && offset.dy.abs() > minDistance;
    }
  }

  Duration _getAnimationDurationForVelocity({
    required Cubic curve,
    required Tween<Offset> tween,
    required Offset targetPixelPerSecond,
  }) {
    assert(targetPixelPerSecond != Offset.zero);
    // find initial animation velocity over the first 20% of the specified curve
    const t = 0.2;
    final animationVelocity = (tween.end! - tween.begin!).distance * curve.transform(t) / t;
    final gestureVelocity = targetPixelPerSecond.distance;
    return Duration(milliseconds: gestureVelocity != 0 ? (animationVelocity / gestureVelocity * 1000).round() : 0);
  }

  void onTap(TapUpDetails details) {
    final onTap = widget.onTap;
    if (onTap == null) return;

    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    final viewportTapPosition = details.localPosition;
    final viewportSize = boundaries.viewportSize;
    final alignment = Alignment(viewportTapPosition.dx / viewportSize.width, viewportTapPosition.dy / viewportSize.height);
    final childTapPosition = boundaries.viewportToChildPosition(controller, viewportTapPosition);

    onTap(context, controller.currentState, alignment, childTapPosition);
  }

  void onDoubleTap(TapDownDetails details) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    final viewportTapPosition = details.localPosition;
    final onDoubleTap = widget.onDoubleTap;
    if (onDoubleTap != null) {
      final viewportSize = boundaries.viewportSize;
      final alignment = Alignment(viewportTapPosition.dx / viewportSize.width, viewportTapPosition.dy / viewportSize.height);
      if (onDoubleTap(alignment) == true) return;
    }

    final childTapPosition = boundaries.viewportToChildPosition(controller, viewportTapPosition);
    nextScaleState(ChangeSource.gesture, childFocalPoint: childTapPosition);
  }

  void animateScale(double? from, double? to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to).animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      onAnimationStatusCompleted();
    }
  }

  /// Check if scale is equal to initial after scale animation update
  void onAnimationStatusCompleted() {
    if (controller.scaleState.state != ScaleState.initial && scale == scaleBoundaries?.initialScale) {
      controller.setScaleState(ScaleState.initial, ChangeSource.animation);
    }
  }

  void animateOnScaleStateUpdate(double? prevScale, double? nextScale, Offset nextPosition) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, nextPosition);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.controller.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.controller.scaleBoundaries;
    }

    return StreamBuilder<MagnifierState>(
      stream: controller.stateStream,
      initialData: controller.previousState,
      builder: (context, snapshot) {
        final boundaries = scaleBoundaries;
        if (!snapshot.hasData || boundaries == null) return const SizedBox();

        final magnifierState = snapshot.data!;
        final position = magnifierState.position;
        final applyScale = widget.applyScale;

        Widget child = CustomSingleChildLayout(
          delegate: _CenterWithOriginalSizeDelegate(
            boundaries.childSize,
            basePosition,
            applyScale,
          ),
          child: widget.child,
        );

        child = Transform(
          transform: Matrix4.identity()
            ..translate(position.dx, position.dy)
            ..scale(applyScale ? scale : 1.0),
          alignment: basePosition,
          child: child,
        );

        return MagnifierGestureDetector(
          hitDetector: this,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          onTapUp: widget.onTap == null ? null : onTap,
          onDoubleTap: onDoubleTap,
          child: child,
        );
      },
    );
  }
}

@immutable
class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate with EquatableMixin {
  final Size subjectSize;
  final Alignment basePosition;
  final bool applyScale;

  @override
  List<Object?> get props => [subjectSize, basePosition, applyScale];

  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.applyScale,
  );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = applyScale ? subjectSize.width : childSize.width;
    final childHeight = applyScale ? subjectSize.height : childSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final offsetX = halfWidth * (basePosition.x + 1);
    final offsetY = halfHeight * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return applyScale ? BoxConstraints.tight(subjectSize) : const BoxConstraints();
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
