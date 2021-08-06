import 'dart:ui';

import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Internal class to wrap custom scale boundaries (min, max and initial)
/// Also, stores values regarding the two sizes: the container and the child.
@immutable
class ScaleBoundaries extends Equatable {
  final ScaleLevel _minScale;
  final ScaleLevel _maxScale;
  final ScaleLevel _initialScale;
  final Size viewportSize;
  final Size childSize;

  @override
  List<Object?> get props => [_minScale, _maxScale, _initialScale, viewportSize, childSize];

  const ScaleBoundaries({
    required ScaleLevel minScale,
    required ScaleLevel maxScale,
    required ScaleLevel initialScale,
    required this.viewportSize,
    required this.childSize,
  })  : _minScale = minScale,
        _maxScale = maxScale,
        _initialScale = initialScale;

  double _scaleForLevel(ScaleLevel level) {
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

  double get minScale => _scaleForLevel(_minScale);

  double get maxScale => _scaleForLevel(_maxScale).clamp(minScale, double.infinity);

  double get initialScale => _scaleForLevel(_initialScale).clamp(minScale, maxScale);

  Offset get _viewportCenter => viewportSize.center(Offset.zero);

  Offset get _childCenter => childSize.center(Offset.zero);

  Offset viewportToStatePosition(MagnifierController controller, Offset viewportPosition) {
    return viewportPosition - _viewportCenter - controller.position;
  }

  Offset viewportToChildPosition(MagnifierController controller, Offset viewportPosition) {
    return viewportToStatePosition(controller, viewportPosition) / controller.scale! + _childCenter;
  }

  Offset childToStatePosition(double scale, Offset childPosition) {
    return (_childCenter - childPosition) * scale;
  }
}
