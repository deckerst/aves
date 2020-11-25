import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/widgets.dart';

class TileExtentManager {
  static const int columnCountMin = 2;
  static const int columnCountDefault = 4;
  static const double tileExtentMin = 46.0;
  static const viewportSizeMin = Size.square(tileExtentMin * columnCountMin);

  static double applyTileExtent(
    Size viewportSize,
    ValueNotifier<double> extentNotifier, {
    double userPreferredExtent = 0,
  }) {
    // sanitize screen size (useful when reloading while screen is off, reporting a 0,0 size)
    viewportSize = Size(max(viewportSize.width, viewportSizeMin.width), max(viewportSize.height, viewportSizeMin.height));

    final oldUserPreferredExtent = settings.collectionTileExtent;
    final currentExtent = extentNotifier.value;
    final targetExtent = userPreferredExtent > 0
        ? userPreferredExtent
        : oldUserPreferredExtent > 0
            ? oldUserPreferredExtent
            : currentExtent;

    int columnCount;
    if (targetExtent > 0) {
      columnCount = max(columnCountMin, (viewportSize.width / targetExtent.clamp(tileExtentMin, extentMaxForSize(viewportSize))).round());
    } else {
      columnCount = columnCountDefault;
    }
    final newExtent = viewportSize.width / columnCount;

    if (userPreferredExtent > 0 || oldUserPreferredExtent == 0) {
      settings.collectionTileExtent = newExtent;
    }
    if (extentNotifier.value != newExtent) {
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  static double extentMaxForSize(Size viewportSize) => viewportSize.shortestSide / columnCountMin;
}
