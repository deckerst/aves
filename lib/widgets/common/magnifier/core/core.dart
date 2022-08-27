import 'dart:math';

import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/controller_delegate.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/gesture_detector.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/pan/corner_hit_detector.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to the controller state and mounts the entire Layout
class MagnifierCore extends StatefulWidget {
  final MagnifierController controller;
  final ScaleStateCycle scaleStateCycle;
  final bool applyScale;
  final double panInertia;
  final MagnifierTapCallback? onTap;
  final MagnifierDoubleTapCallback? onDoubleTap;
  final Widget child;

  const MagnifierCore({
    super.key,
    required this.controller,
    required this.scaleStateCycle,
    required this.applyScale,
    this.panInertia = .2,
    this.onTap,
    this.onDoubleTap,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _MagnifierCoreState();
}

class _MagnifierCoreState extends State<MagnifierCore> with TickerProviderStateMixin, MagnifierControllerDelegate, CornerHitDetector {
  Offset? _startFocalPoint, _lastViewportFocalPosition;
  double? _startScale, _quickScaleLastY, _quickScaleLastDistance;
  late bool _doubleTap, _quickScaleMoved;
  DateTime _lastScaleGestureDate = DateTime.now();

  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  late AnimationController _positionAnimationController;
  late Animation<Offset> _positionAnimation;

  ScaleBoundaries? cachedScaleBoundaries;

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

  void onScaleStart(ScaleStartDetails details, bool doubleTap) {
    _startScale = scale;
    _startFocalPoint = details.localFocalPoint;
    _lastViewportFocalPosition = _startFocalPoint;
    _doubleTap = doubleTap;
    _quickScaleLastDistance = null;
    _quickScaleLastY = _startFocalPoint!.dy;
    _quickScaleMoved = false;

    _scaleAnimationController.stop();
    _positionAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    double newScale;
    if (_doubleTap) {
      // quick scale, aka one finger zoom
      // magic numbers from `davemorrissey/subsampling-scale-image-view`
      final focalPointY = details.focalPoint.dy;
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
    final scaleFocalPoint = _doubleTap ? _startFocalPoint! : details.focalPoint;

    final panPositionDelta = scaleFocalPoint - _lastViewportFocalPosition!;
    final scalePositionDelta = scaleBoundaries.viewportToStatePosition(controller, scaleFocalPoint) * (scale! / newScale - 1);
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
    final _position = controller.position;
    final _scale = controller.scale!;
    final maxScale = scaleBoundaries.maxScale;
    final minScale = scaleBoundaries.minScale;

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
    return Duration(milliseconds: (animationVelocity / gestureVelocity * 1000).round());
  }

  void onTap(TapUpDetails details) {
    final onTap = widget.onTap;
    if (onTap == null) return;

    final viewportTapPosition = details.localPosition;
    final alignment = Alignment(viewportTapPosition.dx / viewportSize.width, viewportTapPosition.dy / viewportSize.height);
    final childTapPosition = scaleBoundaries.viewportToChildPosition(controller, viewportTapPosition);
    onTap(context, controller.currentState, alignment, childTapPosition);
  }

  void onDoubleTap(TapDownDetails details) {
    final viewportTapPosition = details.localPosition;
    if (widget.onDoubleTap != null) {
      final viewportSize = scaleBoundaries.viewportSize;
      final alignment = Alignment(viewportTapPosition.dx / viewportSize.width, viewportTapPosition.dy / viewportSize.height);
      if (widget.onDoubleTap?.call(alignment) == true) return;
    }

    final childTapPosition = scaleBoundaries.viewportToChildPosition(controller, viewportTapPosition);
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
    if (controller.scaleState.state != ScaleState.initial && scale == scaleBoundaries.initialScale) {
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
          if (!snapshot.hasData) return Container();

          final magnifierState = snapshot.data!;
          final position = magnifierState.position;
          final applyScale = widget.applyScale;

          Widget child = CustomSingleChildLayout(
            delegate: _CenterWithOriginalSizeDelegate(
              scaleBoundaries.childSize,
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
            onDoubleTap: onDoubleTap,
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            onScaleEnd: onScaleEnd,
            hitDetector: this,
            onTapUp: widget.onTap == null ? null : onTap,
            child: child,
          );
        });
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
