import 'dart:math';

import 'package:aves/model/settings.dart';
import 'package:flutter/widgets.dart';

class TileExtentManager {
  static const int columnCountMin = 2;
  static const int columnCountDefault = 4;
  static const double tileExtentMin = 46.0;

  static double applyTileExtent(Size mqSize, double mqHorizontalPadding, ValueNotifier<double> extentNotifier, {double newExtent}) {
    final availableWidth = mqSize.width - mqHorizontalPadding;
    var numColumns;
    if ((newExtent ?? 0) == 0) {
      newExtent = extentNotifier.value;
    }
    if ((newExtent ?? 0) == 0) {
      newExtent = settings.collectionTileExtent;
    }
    if ((newExtent ?? 0) == 0) {
      numColumns = columnCountDefault;
    } else {
      newExtent = newExtent.clamp(tileExtentMin, extentMaxForSize(mqSize));
      numColumns = max(columnCountMin, (availableWidth / newExtent).round());
    }
    newExtent = availableWidth / numColumns;
    if (extentNotifier.value != newExtent) {
      settings.collectionTileExtent = newExtent;
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  static double extentMaxForSize(Size mqSize) {
    return mqSize.shortestSide / columnCountMin;
  }
}
