import 'dart:async';
import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:leak_tracker/leak_tracker.dart';

class TileExtentController {
  final String settingsRouteKey;
  final int columnCountMin, columnCountDefault;
  final double extentMin, extentMax, spacing, horizontalPadding;
  late final ValueNotifier<double> extentNotifier;

  late double userPreferredExtent;
  Size _viewportSize = Size.zero;
  final List<StreamSubscription> _subscriptions = [];

  Size get viewportSize => _viewportSize;

  TileExtentController({
    required this.settingsRouteKey,
    this.columnCountMin = 2,
    required this.columnCountDefault,
    required this.extentMin,
    required this.extentMax,
    required this.spacing,
    required this.horizontalPadding,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$TileExtentController',
        object: this,
      );
    }
    // initialize extent to 0, so that it will be dynamically sized on first launch
    extentNotifier = ValueNotifier(0);
    userPreferredExtent = settings.getTileExtent(settingsRouteKey);
    _subscriptions.add(settings.updateTileExtentStream.listen((_) => _onSettingsChanged()));
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
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

  double setUserPreferredColumnCount(int columnCount) => _update(userPreferredExtent: _extentForColumnCount(columnCount));

  double setUserPreferredExtent(double extent) => _update(userPreferredExtent: extent.roundToDouble());

  double _update({double? userPreferredExtent}) {
    final preferredExtent = userPreferredExtent ?? settings.getTileExtent(settingsRouteKey);
    final targetExtent = preferredExtent > 0 ? preferredExtent : extentNotifier.value;

    final columnCount = _effectiveColumnCountForExtent(targetExtent);
    final newExtent = _extentForColumnCount(columnCount).clamp(effectiveExtentMin, effectiveExtentMax);

    if (this.userPreferredExtent != preferredExtent) {
      this.userPreferredExtent = preferredExtent;
      settings.setTileExtent(settingsRouteKey, preferredExtent);
    }
    if (extentNotifier.value != newExtent) {
      extentNotifier.value = newExtent;
    }
    return newExtent;
  }

  double _extentMax() => min(extentMax, (viewportSize.shortestSide - (horizontalPadding * 2) - spacing * (columnCountMin - 1)) / columnCountMin);

  double _columnCountForExtent(double extent) => (viewportSize.width - (horizontalPadding * 2) + spacing) / (extent + spacing);

  double _extentForColumnCount(int columnCount) => (viewportSize.width - (horizontalPadding * 2) - spacing * (columnCount - 1)) / columnCount;

  int _effectiveColumnCountMin() => max(columnCountMin, _columnCountForExtent(_extentMax()).ceil());

  int _effectiveColumnCountMax() => max(columnCountMin, _columnCountForExtent(extentMin).floor());

  int _effectiveColumnCountForExtent(double extent) {
    if (extent > 0) {
      final columnCount = _columnCountForExtent(extent);
      final countMax = _effectiveColumnCountMax();
      final countMin = min(_effectiveColumnCountMin(), countMax);
      return columnCount.round().clamp(countMin, countMax);
    }
    return columnCountDefault;
  }

  double get effectiveExtentMin => min(_extentForColumnCount(_effectiveColumnCountMax()), effectiveExtentMax);

  double get effectiveExtentMax => _extentForColumnCount(_effectiveColumnCountMin());

  (int min, int max) get effectiveColumnRange => (_effectiveColumnCountMin(), _effectiveColumnCountMax());

  int get columnCount => _effectiveColumnCountForExtent(extentNotifier.value);

  Duration getTileAnimationDelay(Duration pageTarget) {
    final extent = extentNotifier.value;
    final columnCount = ((viewportSize.width - (horizontalPadding * 2) + spacing) / (extent + spacing)).round();
    final rowCount = (viewportSize.height + spacing) ~/ (extent + spacing);
    return pageTarget ~/ (columnCount + rowCount) * timeDilation;
  }
}
