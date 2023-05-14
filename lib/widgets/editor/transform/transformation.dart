import 'dart:math' as math;

import 'package:aves/widgets/editor/transform/crop_region.dart';
import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart';

@immutable
class Transformation extends Equatable {
  final TransformOrientation orientation;
  final double straightenDegrees;
  final CropRegion region;

  @override
  List<Object?> get props => [orientation, straightenDegrees, region];

  static const zero = Transformation(
    orientation: TransformOrientation.normal,
    straightenDegrees: 0,
    region: CropRegion.zero,
  );

  const Transformation({
    required this.orientation,
    required this.straightenDegrees,
    required this.region,
  });

  Transformation copyWith({
    TransformOrientation? orientation,
    double? straightenDegrees,
    CropRegion? region,
  }) {
    return Transformation(
      orientation: orientation ?? this.orientation,
      straightenDegrees: straightenDegrees ?? this.straightenDegrees,
      region: region ?? this.region,
    );
  }

  Matrix4 get matrix => _orientationMatrix..multiply(_straightenMatrix);

  Matrix4 get _orientationMatrix {
    final matrix = Matrix4.identity();
    switch (orientation) {
      case TransformOrientation.normal:
        break;
      case TransformOrientation.rotate90:
        matrix.rotateZ(math.pi / 2);
        break;
      case TransformOrientation.rotate180:
        matrix.rotateZ(math.pi);
        break;
      case TransformOrientation.rotate270:
        matrix.rotateZ(3 * math.pi / 2);
        break;
      case TransformOrientation.transverse:
        matrix.scale(-1.0, 1.0, 1.0);
        matrix.rotateZ(-3 * math.pi / 2);
        break;
      case TransformOrientation.flipVertical:
        matrix.scale(1.0, -1.0, 1.0);
        break;
      case TransformOrientation.transpose:
        matrix.scale(-1.0, 1.0, 1.0);
        matrix.rotateZ(-1 * math.pi / 2);
        break;
      case TransformOrientation.flipHorizontal:
        matrix.scale(-1.0, 1.0, 1.0);
        break;
    }
    return matrix;
  }

  Matrix4 get _straightenMatrix => Matrix4.rotationZ(degToRadian((orientation.isFlipped ? -1 : 1) * straightenDegrees));
}

@immutable
class TransformEvent {
  final TransformActivity activity;

  const TransformEvent({
    required this.activity,
  });
}
