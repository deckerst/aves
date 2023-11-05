import 'dart:async';

import 'package:aves_magnifier/src/controller/controller.dart';
import 'package:aves_magnifier/src/controller/state.dart';
import 'package:aves_magnifier/src/core/core.dart';
import 'package:aves_magnifier/src/scale/scale_boundaries.dart';
import 'package:aves_magnifier/src/scale/state.dart';
import 'package:flutter/widgets.dart';

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin AvesMagnifierControllerDelegate on State<AvesMagnifier> {
  AvesMagnifierController get controller => widget.controller;

  ScaleBoundaries? get scaleBoundaries => controller.scaleBoundaries;

  ScaleStateCycle get scaleStateCycle => widget.scaleStateCycle;

  Alignment get basePosition => ScaleBoundaries.basePosition;

  Function(double? prevScale, double? nextScale, Offset nextPosition)? _animateScale;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  final List<StreamSubscription> _subscriptions = [];

  void registerDelegate(AvesMagnifier widget) {
    _subscriptions.add(widget.controller.stateStream.listen(_onMagnifierStateChanged));
    _subscriptions.add(widget.controller.scaleStateChangeStream.listen(_onScaleStateChanged));
  }

  void unregisterDelegate(AvesMagnifier oldWidget) {
    _animateScale = null;
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  void _onScaleStateChanged(ScaleStateChange scaleStateChange) {
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
      final boundaries = scaleBoundaries;
      if (childFocalPoint != null && boundaries != null) {
        nextPosition = boundaries.contentToStatePosition(nextScale!, childFocalPoint);
      }
    }

    final prevScale = controller.scale ?? controller.getScaleForScaleState(controller.previousScaleState.state);
    _animateScale!(prevScale, nextScale, nextPosition);
  }

  void setScaleStateUpdateAnimation(void Function(double? prevScale, double? nextScale, Offset nextPosition) animateScale) {
    _animateScale = animateScale;
  }

  void _onMagnifierStateChanged(MagnifierState state) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    controller.update(position: boundaries.clampPosition(position: position, scale: scale!), source: state.source);
    if (controller.scale == controller.previousState.scale) return;

    if (state.source == ChangeSource.internal || state.source == ChangeSource.animation) return;
    final newScaleState = (scale! > boundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
    controller.setScaleState(newScaleState, state.source);
  }

  Offset get position => controller.position;

  double? recalcScale() {
    final scaleState = controller.scaleState.state;
    final newScale = controller.getScaleForScaleState(scaleState);
    markNeedsScaleRecalc = false;
    setScale(newScale, ChangeSource.internal);
    return newScale;
  }

  double? get scale {
    final scaleState = controller.scaleState.state;
    final needsRecalc = markNeedsScaleRecalc && !(scaleState == ScaleState.zoomedIn || scaleState == ScaleState.zoomedOut);
    final scaleExistsOnController = controller.scale != null;
    if (needsRecalc || !scaleExistsOnController) {
      return recalcScale();
    }
    return controller.scale;
  }

  void setScale(double? scale, ChangeSource source) => controller.update(scale: scale, source: source);

  void updateScaleStateFromNewScale(double newScale, ChangeSource source) {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return;

    var newScaleState = ScaleState.initial;
    if (scale != boundaries.initialScale) {
      newScaleState = (newScale > boundaries.initialScale) ? ScaleState.zoomedIn : ScaleState.zoomedOut;
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
}
