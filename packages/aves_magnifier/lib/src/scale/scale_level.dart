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

  static double scaleForContained(Size containerSize, Size childSize) => min(containerSize.width / childSize.width, containerSize.height / childSize.height);

  static double scaleForCovering(Size containerSize, Size childSize) => max(containerSize.width / childSize.width, containerSize.height / childSize.height);
}

enum ScaleReference { absolute, contained, covered }
