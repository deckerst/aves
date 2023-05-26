import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

@immutable
class ScaleLevel extends Equatable {
  final ScaleReference ref;
  final double factor;

  @override
  List<Object?> get props => [ref, factor];

  const ScaleLevel({
    this.ref = ScaleReference.absolute,
    this.factor = 1.0,
  });

  static double scaleForContained(Size viewportSize, Size contentSize) => min(viewportSize.width / contentSize.width, viewportSize.height / contentSize.height);

  static double scaleForCovering(Size viewportSize, Size contentSize) => max(viewportSize.width / contentSize.width, viewportSize.height / contentSize.height);
}

enum ScaleReference { absolute, contained, covered }
