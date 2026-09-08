import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const EdgeRange(
  final double min,
  final double max,
) extends Equatable {
  @override
  List<Object?> get props => [min, max];

  static const EdgeRange zero = EdgeRange(0, 0);
}
