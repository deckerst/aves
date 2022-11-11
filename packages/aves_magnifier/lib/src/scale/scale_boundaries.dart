import 'dart:math';
import 'dart:ui';

import 'package:aves_magnifier/src/controller/controller.dart';
import 'package:aves_magnifier/src/scale/scale_level.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Internal class to wrap custom scale boundaries (min, max and initial)
/// Also, stores values regarding the two sizes: the container and the child.
@immutable
class ScaleBoundaries extends Equatable {
  final bool _allowOriginalScaleBeyondRange;
  final ScaleLevel _minScale;
  final ScaleLevel _maxScale;
  final ScaleLevel _initialScale;
  final Size viewportSize;
  final Size childSize;

  @override
  List<Object?> get props => [_allowOriginalScaleBeyondRange, _minScale, _maxScale, _initialScale, viewportSize, childSize];

  const ScaleBoundaries({
    required bool allowOriginalScaleBeyondRange,
    required ScaleLevel minScale,
    required ScaleLevel maxScale,
    required ScaleLevel initialScale,
    required this.viewportSize,
    required this.childSize,
  })  : _allowOriginalScaleBeyondRange = allowOriginalScaleBeyondRange,
        _minScale = minScale,
        _maxScale = maxScale,
        _initialScale = initialScale;

  ScaleBoundaries copyWith({
    Size? childSize,
  }) {
    return ScaleBoundaries(
      allowOriginalScaleBeyondRange: _allowOriginalScaleBeyondRange,
      minScale: _minScale,
      maxScale: _maxScale,
      initialScale: _initialScale,
      viewportSize: viewportSize,
      childSize: childSize ?? this.childSize,
    );
  }

  double scaleForLevel(ScaleLevel level) {
    final factor = level.factor;
    switch (level.ref) {
      case ScaleReference.contained:
        return factor * ScaleLevel.scaleForContained(viewportSize, childSize);
      case ScaleReference.covered:
        return factor * ScaleLevel.scaleForCovering(viewportSize, childSize);
      case ScaleReference.absolute:
      default:
        return factor;
    }
  }

  double get originalScale => 1.0 / window.devicePixelRatio;

  double get minScale => {
        scaleForLevel(_minScale),
        _allowOriginalScaleBeyondRange ? originalScale : double.infinity,
        initialScale,
      }.fold(double.infinity, min);

  double get maxScale => {
        scaleForLevel(_maxScale),
        _allowOriginalScaleBeyondRange ? originalScale : double.negativeInfinity,
        initialScale,
      }.fold(0, max);

  double get initialScale => scaleForLevel(_initialScale);

  Offset get _viewportCenter => viewportSize.center(Offset.zero);

  Offset get _childCenter => childSize.center(Offset.zero);

  Offset viewportToStatePosition(AvesMagnifierController controller, Offset viewportPosition) {
    return viewportPosition - _viewportCenter - controller.position;
  }

  Offset viewportToChildPosition(AvesMagnifierController controller, Offset viewportPosition) {
    return viewportToStatePosition(controller, viewportPosition) / controller.scale! + _childCenter;
  }

  Offset childToStatePosition(double scale, Offset childPosition) {
    return (_childCenter - childPosition) * scale;
  }
}
