import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/controller_delegate.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/gesture_detector.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/pan/corner_hit_detector.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/widgets.dart';

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to the controller state and mounts the entire Layout
class MagnifierCore extends StatefulWidget {
  const MagnifierCore({
    Key key,
    @required this.child,
    @required this.onTap,
    @required this.gestureDetectorBehavior,
    @required this.controller,
    @required this.scaleStateCycle,
    @required this.applyScale,
    this.panInertia = .2,
  }) : super(key: key);

  final Widget child;

  final MagnifierController controller;
  final ScaleStateCycle scaleStateCycle;

  final MagnifierTapCallback onTap;

  final HitTestBehavior gestureDetectorBehavior;
  final bool applyScale;
  final double panInertia;

  @override
  State<StatefulWidget> createState() {
    return MagnifierCoreState();
  }
}

class MagnifierCoreState extends State<MagnifierCore> with TickerProviderStateMixin, MagnifierControllerDelegate, CornerHitDetector {
  Offset _startFocalPoint, _lastViewportFocalPosition;
  double _startScale, _quickScaleLastY, _quickScaleLastDistance;
  bool _doubleTap, _quickScaleMoved;
  DateTime _lastScaleGestureDate = DateTime.now();

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  ScaleBoundaries cachedScaleBoundaries;

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
    _quickScaleLastY = _startFocalPoint.dy;
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
      final distance = (focalPointY - _startFocalPoint.dy).abs() * 2 + 20;
      _quickScaleLastDistance ??= distance;
      final spanDiff = (1 - (distance / _quickScaleLastDistance)).abs() * .5;
      _quickScaleMoved |= spanDiff > .03;
      final factor = _quickScaleMoved ? (focalPointY > _quickScaleLastY ? (1 + spanDiff) : (1 - spanDiff)) : 1;
      _quickScaleLastDistance = distance;
      _quickScaleLastY = focalPointY;
      newScale = scale * factor;
    } else {
      newScale = _startScale * details.scale;
    }
    final scaleFocalPoint = _doubleTap ? _startFocalPoint : details.focalPoint;

    final panPositionDelta = scaleFocalPoint - _lastViewportFocalPosition;
    final scalePositionDelta = scaleBoundaries.viewportToStatePosition(controller, scaleFocalPoint) * (scale / newScale - 1);
    final newPosition = position + panPositionDelta + scalePositionDelta;

    updateScaleStateFromNewScale(newScale, ChangeSource.gesture);
    updateMultiple(
      scale: newScale,
      position: newPosition,
      source: ChangeSource.gesture,
    );

    _lastViewportFocalPosition = scaleFocalPoint;
  }

  void onScaleEnd(ScaleEndDetails details) {
    final _position = controller.position;
    final _scale = controller.scale;
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
        final tween = Tween<Offset>(begin: _position, end: newPosition);
        const curve = Curves.easeOutCubic;
        _positionAnimation = tween.animate(CurvedAnimation(parent: _positionAnimationController, curve: curve));
        _positionAnimationController
          ..duration = _getAnimationDurationForVelocity(curve: curve, tween: tween, targetPixelPerSecond: pps)
          ..forward(from: 0.0);
      }
    }

    if (_scale != _startScale) {
      _lastScaleGestureDate = DateTime.now();
    }
  }

  Duration _getAnimationDurationForVelocity({
    Cubic curve,
    Tween<Offset> tween,
    Offset targetPixelPerSecond,
  }) {
    assert(targetPixelPerSecond != Offset.zero);
    // find initial animation velocity over the first 20% of the specified curve
    const t = 0.2;
    final animationVelocity = (tween.end - tween.begin).distance * curve.transform(t) / t;
    final gestureVelocity = targetPixelPerSecond.distance;
    return Duration(milliseconds: (animationVelocity / gestureVelocity * 1000).round());
  }

  void onTap(TapUpDetails details) {
    if (widget.onTap == null) return;

    final viewportTapPosition = details.localPosition;
    final childTapPosition = scaleBoundaries.viewportToChildPosition(controller, viewportTapPosition);
    widget.onTap.call(context, details, controller.currentState, childTapPosition);
  }

  void onDoubleTap(TapDownDetails details) {
    final viewportTapPosition = details?.localPosition;
    final childTapPosition = scaleBoundaries.viewportToChildPosition(controller, viewportTapPosition);
    nextScaleState(ChangeSource.gesture, childFocalPoint: childTapPosition);
  }

  void animateScale(double from, double to) {
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

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(vsync: this)..addListener(handleScaleAnimation);
    _scaleAnimationController.addStatusListener(onAnimationStatus);

    _positionAnimationController = AnimationController(vsync: this)..addListener(handlePositionAnimate);

    startListeners();
    setScaleStateUpdateAnimation(animateOnScaleStateUpdate);

    cachedScaleBoundaries = widget.controller.scaleBoundaries;
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale, Offset nextPosition) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, nextPosition);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    super.dispose();
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

          final magnifierState = snapshot.data;
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
            child: child,
            onDoubleTap: onDoubleTap,
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            onScaleEnd: onScaleEnd,
            hitDetector: this,
            onTapUp: widget.onTap == null ? null : onTap,
          );
        });
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.applyScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool applyScale;

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
    return applyScale ? BoxConstraints.tight(subjectSize) : BoxConstraints();
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is _CenterWithOriginalSizeDelegate && runtimeType == other.runtimeType && subjectSize == other.subjectSize && basePosition == other.basePosition && applyScale == other.applyScale;

  @override
  int get hashCode => hashValues(subjectSize, basePosition, applyScale);
}
