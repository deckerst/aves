import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CropRegion extends Equatable {
  final Offset topLeft, topRight, bottomRight, bottomLeft;

  List<Offset> get corners => [topLeft, topRight, bottomRight, bottomLeft];

  Offset get center => (topLeft + bottomRight) / 2;

  Rect get outsideRect {
    final xMin = corners.map((v) => v.dx).min;
    final xMax = corners.map((v) => v.dx).max;
    final yMin = corners.map((v) => v.dy).min;
    final yMax = corners.map((v) => v.dy).max;
    return Rect.fromPoints(Offset(xMin, yMin), Offset(xMax, yMax));
  }

  @override
  List<Object?> get props => [topLeft, topRight, bottomRight, bottomLeft];

  const CropRegion({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  static const CropRegion zero = CropRegion(
    topLeft: Offset.zero,
    topRight: Offset.zero,
    bottomRight: Offset.zero,
    bottomLeft: Offset.zero,
  );

  factory CropRegion.fromRect(Rect rect) {
    return CropRegion(
      topLeft: rect.topLeft,
      topRight: rect.topRight,
      bottomRight: rect.bottomRight,
      bottomLeft: rect.bottomLeft,
    );
  }
}
