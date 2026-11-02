import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class const ViewState({
  required final Offset position,
  required final double? scale,
  required final Size? viewportSize,
  required final Size? contentSize,
}) extends Equatable {
  static const ViewState zero = ViewState(
    position: Offset.zero,
    scale: 0,
    viewportSize: null,
    contentSize: null,
  );

  @override
  List<Object?> get props => [position, scale, viewportSize, contentSize];

  ViewState copyWith({
    Offset? position,
    double? scale,
    Size? viewportSize,
    Size? contentSize,
  }) {
    return ViewState(
      position: position ?? this.position,
      scale: scale ?? this.scale,
      viewportSize: viewportSize ?? this.viewportSize,
      contentSize: contentSize ?? this.contentSize,
    );
  }

  Matrix4 get matrix {
    final _viewportSize = viewportSize ?? Size.zero;
    final _contentSize = contentSize ?? Size.zero;
    final _scale = scale ?? 1.0;

    final scaledContentSize = _contentSize * _scale;
    final viewOffset = _viewportSize.center(Offset.zero) - scaledContentSize.center(Offset.zero);

    return Matrix4.identity()
      ..translateByDouble(position.dx, position.dy, 0, 1)
      ..translateByDouble(viewOffset.dx, viewOffset.dy, 0, 1)
      ..scaleByDouble(_scale, _scale, 1, 1);
  }
}
