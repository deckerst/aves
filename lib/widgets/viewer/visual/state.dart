import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class ViewState extends Equatable {
  final Offset position;
  final double? scale;
  final Size? viewportSize, contentSize;

  static const ViewState zero = ViewState(
    position: Offset.zero,
    scale: 0,
    viewportSize: null,
    contentSize: null,
  );

  @override
  List<Object?> get props => [position, scale, viewportSize, contentSize];

  const ViewState({
    required this.position,
    required this.scale,
    required this.viewportSize,
    required this.contentSize,
  });

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
}
