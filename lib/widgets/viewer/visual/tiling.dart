import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

class RasterTiling({
  required final int maxSampleSize,
  required final double tileSide,
  required final Matrix4? tileTransform,
}) {
  static const double _tilesByShortestSide = 2;

  factory forEntry({
    required double devicePixelRatio,
    required Size viewportSize,
    required AvesEntry entry,
  }) {
    final entryImageWidth = entry.width;
    final entryImageHeight = entry.height;
    final entryDisplayWidth = entry.displaySize.width;
    final entryDisplayHeight = entry.displaySize.height;
    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;

    final tileSide = viewportSize.shortestSide * devicePixelRatio / _tilesByShortestSide;
    // scale for initial state `contained`
    final containedScale = min(viewportSize.width / entryDisplayWidth, viewportSize.height / entryDisplayHeight);
    final maxSampleSize = ExtraAvesEntryImages.sampleSizeForScale(magnifierScale: containedScale, devicePixelRatio: devicePixelRatio);

    Matrix4? tileTransform;
    if (rotationDegrees != 0 || isFlipped) {
      tileTransform = Matrix4.identity()
        ..translateByDouble(entryImageWidth / 2.0, entryImageHeight / 2.0, 0, 1)
        ..scaleByDouble(isFlipped ? -1.0 : 1.0, 1.0, 1.0, 1.0)
        ..rotateZ(-degToRadian(rotationDegrees.toDouble()))
        ..translateByDouble(-entryDisplayWidth / 2.0, -entryDisplayHeight / 2.0, 0, 1);
    }
    return RasterTiling(
      maxSampleSize: maxSampleSize,
      tileSide: tileSide,
      tileTransform: tileTransform,
    );
  }
}
