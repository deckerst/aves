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
  }) : super(key: key);

  final Widget child;

  final MagnifierController controller;
  final ScaleStateCycle scaleStateCycle;

  final MagnifierTapCallback onTap;

  final HitTestBehavior gestureDetectorBehavior;
  final bool applyScale;

  @override
  State<StatefulWidget> createState() {
    return MagnifierCoreState();
  }
}

class MagnifierCoreState extends State<MagnifierCore> with TickerProviderStateMixin, MagnifierControllerDelegate, CornerHitDetector {
  Offset _prevViewportFocalPosition;
  double _gestureStartScale;

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

  void onScaleStart(ScaleStartDetails details) {
    _gestureStartScale = scale;
    _prevViewportFocalPosition = details.localFocalPoint;

    _scaleAnimationController.stop();
    _positionAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final newScale = _gestureStartScale * details.scale;
    final panPositionDelta = details.focalPoint - _prevViewportFocalPosition;
    final scalePositionDelta = scaleBoundaries.viewportToStatePosition(controller, details.focalPoint) * (scale / newScale - 1);
    final newPosition = position + panPositionDelta + scalePositionDelta;

    updateScaleStateFromNewScale(newScale, ChangeSource.gesture);
    updateMultiple(
      scale: newScale,
      position: newPosition,
      source: ChangeSource.gesture,
    );

    _prevViewportFocalPosition = details.focalPoint;
  }

  void onScaleEnd(ScaleEndDetails details) {
    final _scale = scale;
    final _position = controller.position;
    final maxScale = scaleBoundaries.maxScale;
    final minScale = scaleBoundaries.minScale;

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: maxScale,
      );
      animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
        _position,
        clampPosition(
          position: _position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }
    // get magnitude from gesture velocity
    final magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_gestureStartScale / _scale == 1.0 && magnitude >= 400.0) {
      final direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(
        _position,
        clampPosition(position: _position + direction * 100.0),
      );
    }
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
