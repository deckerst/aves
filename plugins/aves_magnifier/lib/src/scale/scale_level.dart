import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

@immutable
class const ScaleLevel({
  final ScaleReference ref = ScaleReference.absolute,
  final double factor = 1.0,
}) extends Equatable {
  @override
  List<Object?> get props => [ref, factor];

  static double scaleForContained(Size viewportSize, Size contentSize) => min(viewportSize.width / contentSize.width, viewportSize.height / contentSize.height);

  static double scaleForCovering(Size viewportSize, Size contentSize) => max(viewportSize.width / contentSize.width, viewportSize.height / contentSize.height);
}

enum ScaleReference { absolute, contained, covered }
