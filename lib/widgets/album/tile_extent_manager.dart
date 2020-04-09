import 'package:aves/model/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class TileExtentManager {
  static const columnCountMin = 2;
  static const columnCountDefault = 4;
  static const columnCountMax = 8;

  static double applyTileExtent(Size mqSize, EdgeInsets mqPadding, ValueNotifier<double> extentNotifier, {double newExtent}) {
    final availableWidth = mqSize.width - mqPadding.horizontal;
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
      final minMax = extentBoundsForSize(mqSize);
      newExtent = newExtent.clamp(minMax.item1, minMax.item2);
      numColumns = (availableWidth / newExtent).round().clamp(columnCountMin, columnCountMax);
    }
    newExtent = availableWidth / numColumns;
    if (extentNotifier.value != newExtent) {
      settings.collectionTileExtent = newExtent;
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  static Tuple2<double, double> extentBoundsForSize(Size mqSize) {
    final min = mqSize.shortestSide / columnCountMax;
    final max = mqSize.shortestSide / columnCountMin;
    return Tuple2(min, max);
  }
}
