import 'dart:async';

import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/core.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/widgets.dart';

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin MagnifierControllerDelegate on State<MagnifierCore> {
  MagnifierController get controller => widget.controller;

  ScaleBoundaries get scaleBoundaries => controller.scaleBoundaries;

  Size get childSize => scaleBoundaries.childSize;

  Size get viewportSize => scaleBoundaries.viewportSize;

  ScaleStateCycle get scaleStateCycle => widget.scaleStateCycle;

  Alignment get basePosition => Alignment.center;

  Function(double? prevScale, double? nextScale, Offset nextPosition)? _animateScale;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  final List<StreamSubscription> _subscriptions = [];

  void registerDelegate(MagnifierCore widget) {
    _subscriptions.add(widget.controller.stateStream.listen(_onMagnifierStateChange));
    _subscriptions.add(widget.controller.scaleStateChangeStream.listen(_onScaleStateChange));
  }

  void unregisterDelegate(MagnifierCore oldWidget) {
    _animateScale = null;
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  void _onScaleStateChange(ScaleStateChange scaleStateChange) {
    if (scaleStateChange.source == ChangeSource.internal) return;
    if (!controller.hasScaleSateChanged) return;

    if (_animateScale == null || controller.isZooming) {
      controller.update(scale: scale, source: scaleStateChange.source);
      return;
    }

    final nextScaleState = scaleStateChange.state;
    final nextScale = controller.getScaleForScaleState(nextScaleState);
    var nextPosition = Offset.zero;
    if (nextScaleState == ScaleState.covering || nextScaleState == ScaleState.originalSize) {
      final childFocalPoint = scaleStateChange.childFocalPoint;
      if (childFocalPoint != null) {
        nextPosition = scaleBoundaries.childToStatePosition(nextScale!, childFocalPoint);
      }
    }

    final prevScale = controller.scale ?? controller.getScaleForScaleState(controller.previousScaleState.state);
    _animateScale!(prevScale, nextScale, nextPosition);
  }

  void setScaleStateUpdateAnimation(void Function(double? prevScale, double? nextScale, Offset nextPosition) animateScale) {
    _animateScale = animateScale;
  }

  void _onMagnifierStateChange(MagnifierState state) {
    controller.update(position: clampPosition(), source: state.source);
    if (controller.scale == controller.previousState.scale) return;

    if (state.source == ChangeSource.internal || state.source == ChangeSource.animation) return;
    final newScaleState = (scale! > scaleBoundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
    controller.setScaleState(newScaleState, state.source);
  }

  Offset get position => controller.position;

  double? get scale {
    final scaleState = controller.scaleState.state;
    final needsRecalc = markNeedsScaleRecalc && !(scaleState == ScaleState.zoomedIn || scaleState == ScaleState.zoomedOut);
    final scaleExistsOnController = controller.scale != null;
    if (needsRecalc || !scaleExistsOnController) {
      final newScale = controller.getScaleForScaleState(scaleState);
      markNeedsScaleRecalc = false;
      setScale(newScale, ChangeSource.internal);
      return newScale;
    }
    return controller.scale;
  }

  void setScale(double? scale, ChangeSource source) => controller.update(scale: scale, source: source);

  void updateMultiple({
    required Offset position,
    required double scale,
    required ChangeSource source,
  }) {
    controller.update(position: position, scale: scale, source: source);
  }

  void updateScaleStateFromNewScale(double newScale, ChangeSource source) {
    var newScaleState = ScaleState.initial;
    if (scale != scaleBoundaries.initialScale) {
      newScaleState = (newScale > scaleBoundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
    }
    controller.setScaleState(newScaleState, source);
  }

  void nextScaleState(ChangeSource source, {Offset? childFocalPoint}) {
    final scaleState = controller.scaleState.state;
    if (scaleState == ScaleState.zoomedIn || scaleState == ScaleState.zoomedOut) {
      controller.setScaleState(scaleStateCycle(scaleState), source, childFocalPoint: childFocalPoint);
      return;
    }
    final originalScale = controller.getScaleForScaleState(scaleState);

    var prevScale = originalScale;
    var prevScaleState = scaleState;
    var nextScale = originalScale;
    var nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = scaleStateCycle(prevScaleState);
      nextScale = controller.getScaleForScaleState(nextScaleState);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) return;
    controller.setScaleState(nextScaleState, source, childFocalPoint: childFocalPoint);
  }

  CornersRange cornersX({double? scale}) {
    final _scale = scale ?? this.scale!;

    final computedWidth = childSize.width * _scale;
    final screenWidth = viewportSize.width;

    final positionX = basePosition.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return CornersRange(minX, maxX);
  }

  CornersRange cornersY({double? scale}) {
    final _scale = scale ?? this.scale!;

    final computedHeight = childSize.height * _scale;
    final screenHeight = viewportSize.height;

    final positionY = basePosition.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return CornersRange(minY, maxY);
  }

  Offset clampPosition({Offset? position, double? scale}) {
    final _scale = scale ?? this.scale!;
    final _position = position ?? this.position;

    final computedWidth = childSize.width * _scale;
    final computedHeight = childSize.height * _scale;

    final screenWidth = viewportSize.width;
    final screenHeight = viewportSize.height;

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
}

/// Simple class to store a min and a max value
class CornersRange {
  const CornersRange(this.min, this.max);

  final double min;
  final double max;
}
