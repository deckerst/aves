import 'dart:math';

import 'package:aves_magnifier/src/controller/controller.dart';
import 'package:aves_magnifier/src/controller/range.dart';
import 'package:aves_magnifier/src/scale/scale_level.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Internal class to wrap custom scale boundaries (min, max and initial)
/// Also, stores values regarding the two sizes: the container and the content.
@immutable
class ScaleBoundaries extends Equatable {
  final bool _allowOriginalScaleBeyondRange;
  final ScaleLevel _minScale;
  final ScaleLevel _maxScale;
  final ScaleLevel _initialScale;
  final Size viewportSize;
  final Size contentSize;
  final EdgeInsets Function(double scale)? padding;
  final Matrix4? externalTransform;

  static const Alignment basePosition = Alignment.center;

  @override
  List<Object?> get props => [_allowOriginalScaleBeyondRange, _minScale, _maxScale, _initialScale, viewportSize, contentSize, padding, externalTransform];

  const ScaleBoundaries({
    required bool allowOriginalScaleBeyondRange,
    required ScaleLevel minScale,
    required ScaleLevel maxScale,
    required ScaleLevel initialScale,
    required this.viewportSize,
    required this.contentSize,
    this.padding,
    this.externalTransform,
  })  : _allowOriginalScaleBeyondRange = allowOriginalScaleBeyondRange,
        _minScale = minScale,
        _maxScale = maxScale,
        _initialScale = initialScale;

  static const ScaleBoundaries zero = ScaleBoundaries(
    allowOriginalScaleBeyondRange: true,
    minScale: ScaleLevel(factor: .0),
    maxScale: ScaleLevel(factor: double.infinity),
    initialScale: ScaleLevel(ref: ScaleReference.contained),
    viewportSize: Size.zero,
    contentSize: Size.zero,
    padding: null,
  );

  ScaleBoundaries copyWith({
    bool? allowOriginalScaleBeyondRange,
    ScaleLevel? minScale,
    ScaleLevel? maxScale,
    ScaleLevel? initialScale,
    Size? viewportSize,
    Size? contentSize,
    EdgeInsets Function(double scale)? padding,
    Matrix4? externalTransform,
  }) {
    return ScaleBoundaries(
      allowOriginalScaleBeyondRange: allowOriginalScaleBeyondRange ?? _allowOriginalScaleBeyondRange,
      minScale: minScale ?? _minScale,
      maxScale: maxScale ?? _maxScale,
      initialScale: initialScale ?? _initialScale,
      viewportSize: viewportSize ?? this.viewportSize,
      contentSize: contentSize ?? this.contentSize,
      padding: padding ?? this.padding,
      externalTransform: externalTransform ?? this.externalTransform,
    );
  }

  Size get _transformedViewportSize {
    final matrix = externalTransform;
    return matrix != null ? MatrixUtils.transformRect(Matrix4.inverted(matrix), Offset.zero & viewportSize).size : viewportSize;
  }

  double scaleForLevel(ScaleLevel level) {
    final factor = level.factor;
    switch (level.ref) {
      case ScaleReference.contained:
        return factor * ScaleLevel.scaleForContained(viewportSize, contentSize);
      case ScaleReference.covered:
        return factor * ScaleLevel.scaleForCovering(viewportSize, contentSize);
      case ScaleReference.absolute:
        return factor;
    }
  }

  double get originalScale {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    return 1.0 / (view?.devicePixelRatio ?? 1.0);
  }

  double get initialScale => scaleForLevel(_initialScale);

  Offset get viewportCenter => viewportSize.center(Offset.zero);

  Offset get _contentCenter => contentSize.center(Offset.zero);

  Offset viewportToContentPosition(AvesMagnifierController controller, Offset viewportPosition) {
    return (viewportPosition - viewportCenter - controller.position) / controller.scale! + _contentCenter;
  }

  Offset contentToStatePosition(double scale, Offset contentPosition) {
    return (_contentCenter - contentPosition) * scale;
  }

  EdgeRange getXEdges({required double scale}) {
    final computedWidth = contentSize.width * scale;
    final viewportWidth = _transformedViewportSize.width;

    final positionX = basePosition.x;
    final widthDiff = max(0, computedWidth - viewportWidth);

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;
    final _padding = padding?.call(scale) ?? EdgeInsets.zero;
    return EdgeRange(minX - _padding.left, maxX + _padding.right);
  }

  EdgeRange getYEdges({required double scale}) {
    final computedHeight = contentSize.height * scale;
    final viewportHeight = _transformedViewportSize.height;

    final positionY = basePosition.y;
    final heightDiff = max(0, computedHeight - viewportHeight);

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;
    final _padding = padding?.call(scale) ?? EdgeInsets.zero;
    return EdgeRange(minY - _padding.top, maxY + _padding.bottom);
  }

  double clampScale(double scale) {
    final minScale = {
      scaleForLevel(_minScale),
      _allowOriginalScaleBeyondRange ? originalScale : double.infinity,
      initialScale,
    }.fold(double.infinity, min);

    final maxScale = {
      scaleForLevel(_maxScale),
      _allowOriginalScaleBeyondRange ? originalScale : double.negativeInfinity,
      initialScale,
    }.fold(.0, max);

    return scale.clamp(minScale, maxScale);
  }

  Offset clampPosition({required Offset position, required double scale}) {
    final rangeX = getXEdges(scale: scale);
    final rangeY = getYEdges(scale: scale);
    return Offset(
      position.dx.clamp(rangeX.min, rangeX.max),
      position.dy.clamp(rangeY.min, rangeY.max),
    );
  }
}
