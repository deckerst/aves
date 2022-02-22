import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class ViewState extends Equatable {
  final Offset position;
  final double? scale;
  final Size? viewportSize;

  static const ViewState zero = ViewState(Offset.zero, 0, null);

  @override
  List<Object?> get props => [position, scale, viewportSize];

  const ViewState(this.position, this.scale, this.viewportSize);
}
