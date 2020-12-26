import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class ScaleLevel {
  final ScaleReference ref;
  final double factor;

  const ScaleLevel({
    this.ref = ScaleReference.absolute,
    this.factor = 1.0,
  });

  static double scaleForContained(Size containerSize, Size childSize) => min(containerSize.width / childSize.width, containerSize.height / childSize.height);

  static double scaleForCovering(Size containerSize, Size childSize) => max(containerSize.width / childSize.width, containerSize.height / childSize.height);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{ref=$ref, factor=$factor}';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ScaleLevel && other.ref == ref && other.factor == factor;
  }

  @override
  int get hashCode => hashValues(ref, factor);
}

enum ScaleReference { absolute, contained, covered }
