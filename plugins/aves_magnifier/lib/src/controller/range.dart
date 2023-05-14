import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class EdgeRange extends Equatable {
  final double min;
  final double max;

  @override
  List<Object?> get props => [min, max];

  const EdgeRange(this.min, this.max);

  static const EdgeRange zero = EdgeRange(0, 0);
}
