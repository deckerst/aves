import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/widgets.dart';

class TileExtentManager {
  final String settingsRouteKey;
  final int columnCountMin, columnCountDefault;
  final double spacing, extentMin, extentMax;
  final ValueNotifier<double> extentNotifier;

  const TileExtentManager({
    @required this.settingsRouteKey,
    @required this.extentNotifier,
    this.columnCountMin = 2,
    @required this.columnCountDefault,
    @required this.extentMin,
    this.extentMax = 300,
    @required this.spacing,
  });

  double applyTileExtent({
    @required Size viewportSize,
    double userPreferredExtent = 0,
  }) {
    // sanitize screen size (useful when reloading while screen is off, reporting a 0,0 size)
    final viewportSizeMin = Size.square(extentMin * columnCountMin);
    viewportSize = Size(max(viewportSize.width, viewportSizeMin.width), max(viewportSize.height, viewportSizeMin.height));

    final oldUserPreferredExtent = settings.getTileExtent(settingsRouteKey);
    final currentExtent = extentNotifier.value;
    final targetExtent = userPreferredExtent > 0
        ? userPreferredExtent
        : oldUserPreferredExtent > 0
            ? oldUserPreferredExtent
            : currentExtent;

    final columnCount = getEffectiveColumnCountForExtent(viewportSize, targetExtent);
    final newExtent = _extentForColumnCount(viewportSize, columnCount);

    if (userPreferredExtent > 0 || oldUserPreferredExtent == 0) {
      settings.setTileExtent(settingsRouteKey, newExtent);
    }
    if (extentNotifier.value != newExtent) {
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  double _extentMax(Size viewportSize) => min(extentMax, (viewportSize.shortestSide - spacing * (columnCountMin - 1)) / columnCountMin);

  double _columnCountForExtent(Size viewportSize, double extent) => (viewportSize.width + spacing) / (extent + spacing);

  double _extentForColumnCount(Size viewportSize, int columnCount) => (viewportSize.width - spacing * (columnCount - 1)) / columnCount;

  int _effectiveColumnCountMin(Size viewportSize) => _columnCountForExtent(viewportSize, _extentMax(viewportSize)).ceil();

  int _effectiveColumnCountMax(Size viewportSize) => _columnCountForExtent(viewportSize, extentMin).floor();

  double getEffectiveExtentMin(Size viewportSize) => _extentForColumnCount(viewportSize, _effectiveColumnCountMax(viewportSize));

  double getEffectiveExtentMax(Size viewportSize) => _extentForColumnCount(viewportSize, _effectiveColumnCountMin(viewportSize));

  int getEffectiveColumnCountForExtent(Size viewportSize, double extent) {
    if (extent > 0) {
      final columnCount = _columnCountForExtent(viewportSize, extent);
      return columnCount.clamp(_effectiveColumnCountMin(viewportSize), _effectiveColumnCountMax(viewportSize)).round();
    }
    return columnCountDefault;
  }
}
