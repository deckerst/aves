import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CropRegion extends Equatable {
  // region corners in image pixel coordinates
  final Offset topLeft, topRight, bottomRight, bottomLeft;

  List<Offset> get corners => [topLeft, topRight, bottomRight, bottomLeft];

  Offset get center => (topLeft + bottomRight) / 2;

  @override
  List<Object?> get props => [topLeft, topRight, bottomRight, bottomLeft];

  const CropRegion({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  static const zero = CropRegion(
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
