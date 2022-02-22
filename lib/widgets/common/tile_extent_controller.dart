import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class TileExtentController {
  final String settingsRouteKey;
  final int columnCountMin, columnCountDefault;
  final double spacing, extentMin, extentMax;
  final ValueNotifier<double> extentNotifier = ValueNotifier(0);

  late double userPreferredExtent;
  Size _viewportSize = Size.zero;

  Size get viewportSize => _viewportSize;

  TileExtentController({
    required this.settingsRouteKey,
    this.columnCountMin = 2,
    required this.columnCountDefault,
    required this.extentMin,
    required this.extentMax,
    required this.spacing,
  }) {
    userPreferredExtent = settings.getTileExtent(settingsRouteKey);
    settings.addListener(_onSettingsChanged);
  }

  void dispose() {
    settings.removeListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (userPreferredExtent != settings.getTileExtent(settingsRouteKey)) {
      _update();
    }
  }

  void setViewportSize(Size viewportSize) {
    // sanitize screen size (useful when reloading while screen is off, reporting a 0,0 size)
    final viewportSizeMin = Size.square(extentMin * columnCountMin);
    // dimensions are rounded to prevent updates on minor changes
    // e.g. available space on S10e is `Size(360.0, 721.0)` when status bar is visible, `Size(360.0, 721.3)` when it is not
    final newViewportSize = Size(max(viewportSize.width, viewportSizeMin.width).roundToDouble(), max(viewportSize.height, viewportSizeMin.height).roundToDouble());
    if (_viewportSize != newViewportSize) {
      _viewportSize = newViewportSize;
      _update();
    }
  }

  double setUserPreferredExtent(double extent) => _update(userPreferredExtent: extent.roundToDouble());

  double _update({double? userPreferredExtent}) {
    final preferredExtent = userPreferredExtent ?? settings.getTileExtent(settingsRouteKey);
    final targetExtent = preferredExtent > 0 ? preferredExtent : extentNotifier.value;

    final columnCount = _effectiveColumnCountForExtent(targetExtent);
    final newExtent = _extentForColumnCount(columnCount);

    if (this.userPreferredExtent != preferredExtent) {
      this.userPreferredExtent = preferredExtent;
      settings.setTileExtent(settingsRouteKey, preferredExtent);
    }
    if (extentNotifier.value != newExtent) {
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  double _extentMax() => min(extentMax, (viewportSize.shortestSide - spacing * (columnCountMin - 1)) / columnCountMin);

  double _columnCountForExtent(double extent) => (viewportSize.width + spacing) / (extent + spacing);

  double _extentForColumnCount(int columnCount) => (viewportSize.width - spacing * (columnCount - 1)) / columnCount;

  int _effectiveColumnCountMin() => _columnCountForExtent(_extentMax()).ceil();

  int _effectiveColumnCountMax() => _columnCountForExtent(extentMin).floor();

  int _effectiveColumnCountForExtent(double extent) {
    if (extent > 0) {
      final columnCount = _columnCountForExtent(extent);
      return columnCount.clamp(_effectiveColumnCountMin(), _effectiveColumnCountMax()).round();
    }
    return columnCountDefault;
  }

  double get effectiveExtentMin => _extentForColumnCount(_effectiveColumnCountMax());

  double get effectiveExtentMax => _extentForColumnCount(_effectiveColumnCountMin());

  int get columnCount => _effectiveColumnCountForExtent(extentNotifier.value);

  Duration getTileAnimationDelay(Duration pageTarget) {
    final extent = extentNotifier.value;
    final columnCount = ((viewportSize.width + spacing) / (extent + spacing)).round();
    final rowCount = (viewportSize.height + spacing) ~/ (extent + spacing);
    return pageTarget ~/ (columnCount + rowCount) * timeDilation;
  }
}
