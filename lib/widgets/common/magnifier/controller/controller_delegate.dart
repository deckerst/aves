import 'dart:async';
import 'dart:ui';

import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/core.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/scalestate_controller.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/widgets.dart';

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin MagnifierControllerDelegate on State<MagnifierCore> {
  MagnifierController get controller => widget.controller;

  MagnifierScaleStateController get scaleStateController => widget.scaleStateController;

  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;

  ScaleStateCycle get scaleStateCycle => widget.scaleStateCycle;

  Alignment get basePosition => Alignment.center;

  Function(double prevScale, double nextScale, Offset nextPosition) _animateScale;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  final List<StreamSubscription> _streamSubs = [];

  void startListeners() {
    _streamSubs.add(controller.outputStateStream.listen(_onMagnifierStateChange));
    _streamSubs.add(scaleStateController.scaleStateChangeStream.listen(_onScaleStateChange));
  }

  void _onScaleStateChange(ScaleStateChange scaleStateChange) {
    if (scaleStateChange.source == ChangeSource.internal) return;
    if (!scaleStateController.hasChanged) return;

    if (_animateScale == null || scaleStateController.isZooming) {
      controller.setScale(scale, scaleStateChange.source);
      return;
    }

    final nextScaleState = scaleStateChange.state;
    final nextScale = getScaleForScaleState(nextScaleState, scaleBoundaries);
    var nextPosition = Offset.zero;
    if (nextScaleState == ScaleState.covering || nextScaleState == ScaleState.originalSize) {
      final childFocalPoint = scaleStateChange.childFocalPoint;
      if (childFocalPoint != null) {
        final childCenter = scaleBoundaries.childSize.center(Offset.zero);
        nextPosition = (childCenter - childFocalPoint) * nextScale;
      }
    }

    final prevScale = controller.scale ?? getScaleForScaleState(scaleStateController.prevScaleState.state, scaleBoundaries);
    _animateScale(prevScale, nextScale, nextPosition);
  }

  void addAnimateOnScaleStateUpdate(void Function(double prevScale, double nextScale, Offset nextPosition) animateScale) {
    _animateScale = animateScale;
  }

  void _onMagnifierStateChange(MagnifierState state) {
    controller.setPosition(clampPosition(), state.source);
    if (controller.scale == controller.prevValue.scale) return;

    if (state.source == ChangeSource.internal || state.source == ChangeSource.animation) return;
    final newScaleState = (scale > scaleBoundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
    scaleStateController.setScaleState(newScaleState, state.source);
  }

  Offset get position => controller.position;

  double get scale {
    final scaleState = scaleStateController.scaleState.state;
    final needsRecalc = markNeedsScaleRecalc && !(scaleState == ScaleState.zoomedIn || scaleState == ScaleState.zoomedOut);
    final scaleExistsOnController = controller.scale != null;
    if (needsRecalc || !scaleExistsOnController) {
      final newScale = getScaleForScaleState(scaleState, scaleBoundaries);
      markNeedsScaleRecalc = false;
      setScale(newScale, ChangeSource.internal);
      return newScale;
    }
    return controller.scale;
  }

  void setScale(double scale, ChangeSource source) => controller.setScale(scale, source);

  void updateMultiple({
    Offset position,
    double scale,
    @required ChangeSource source,
  }) {
    controller.updateMultiple(position: position, scale: scale, source: source);
  }

  void updateScaleStateFromNewScale(double newScale, ChangeSource source) {
    // debugPrint('updateScaleStateFromNewScale scale=$newScale, source=$source');
    var newScaleState = ScaleState.initial;
    if (scale != scaleBoundaries.initialScale) {
      newScaleState = (newScale > scaleBoundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
    }
    scaleStateController.setScaleState(newScaleState, source);
  }

  void nextScaleState(ChangeSource source, {Offset childFocalPoint}) {
    // debugPrint('$runtimeType nextScaleState source=$source');
    final scaleState = scaleStateController.scaleState.state;
    if (scaleState == ScaleState.zoomedIn || scaleState == ScaleState.zoomedOut) {
      scaleStateController.setScaleState(scaleStateCycle(scaleState), source, childFocalPoint: childFocalPoint);
      return;
    }
    final originalScale = getScaleForScaleState(
      scaleState,
      scaleBoundaries,
    );

    var prevScale = originalScale;
    var prevScaleState = scaleState;
    var nextScale = originalScale;
    var nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = scaleStateCycle(prevScaleState);
      nextScale = getScaleForScaleState(nextScaleState, scaleBoundaries);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) return;
    scaleStateController.setScaleState(nextScaleState, source, childFocalPoint: childFocalPoint);
  }

  CornersRange cornersX({double scale}) {
    final _scale = scale ?? this.scale;

    final computedWidth = scaleBoundaries.childSize.width * _scale;
    final screenWidth = scaleBoundaries.viewportSize.width;

    final positionX = basePosition.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return CornersRange(minX, maxX);
  }

  CornersRange cornersY({double scale}) {
    final _scale = scale ?? this.scale;

    final computedHeight = scaleBoundaries.childSize.height * _scale;
    final screenHeight = scaleBoundaries.viewportSize.height;

    final positionY = basePosition.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return CornersRange(minY, maxY);
  }

  Offset clampPosition({Offset position, double scale}) {
    final _scale = scale ?? this.scale;
    final _position = position ?? this.position;

    final computedWidth = scaleBoundaries.childSize.width * _scale;
    final computedHeight = scaleBoundaries.childSize.height * _scale;

    final screenWidth = scaleBoundaries.viewportSize.width;
    final screenHeight = scaleBoundaries.viewportSize.height;

    var finalX = 0.0;
    if (screenWidth < computedWidth) {
      final cornersX = this.cornersX(scale: _scale);
      finalX = _position.dx.clamp(cornersX.min, cornersX.max);
    }

    var finalY = 0.0;
    if (screenHeight < computedHeight) {
      final cornersY = this.cornersY(scale: _scale);
      finalY = _position.dy.clamp(cornersY.min, cornersY.max);
    }

    return Offset(finalX, finalY);
  }

  @override
  void dispose() {
    _animateScale = null;
    _streamSubs.forEach((sub) => sub.cancel());
    _streamSubs.clear();
    super.dispose();
  }

  double getScaleForScaleState(
    ScaleState scaleState,
    ScaleBoundaries scaleBoundaries,
  ) {
    double _clamp(double scale, ScaleBoundaries boundaries) => scale.clamp(boundaries.minScale, boundaries.maxScale);

    switch (scaleState) {
      case ScaleState.initial:
      case ScaleState.zoomedIn:
      case ScaleState.zoomedOut:
        return _clamp(scaleBoundaries.initialScale, scaleBoundaries);
      case ScaleState.covering:
        return _clamp(ScaleLevel.scaleForCovering(scaleBoundaries.viewportSize, scaleBoundaries.childSize), scaleBoundaries);
      case ScaleState.originalSize:
        return _clamp(1.0, scaleBoundaries);
      default:
        return null;
    }
  }
}

/// Simple class to store a min and a max value
class CornersRange {
  const CornersRange(this.min, this.max);

  final double min;
  final double max;
}
