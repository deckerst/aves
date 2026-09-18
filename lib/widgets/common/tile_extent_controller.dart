import 'dart:async';
import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:leak_tracker/leak_tracker.dart';

class TileExtentController({
  required final String? settingsRouteKey,
  final int columnCountMin = 2,
  required final int columnCountDefault,
  required final double extentMin,
  required final double extentMax,
  required final double spacing,
  required final double horizontalPadding,
}) {
  static const double _defaultExtent = 0;

  final ValueNotifier<double> extentNotifier = ValueNotifier(_defaultExtent);
  double userPreferredExtent = _defaultExtent;
  Size _viewportSize = Size.zero;
  final Set<StreamSubscription> _subscriptions = {};

  Size get viewportSize => _viewportSize;

  double get _settingsTileExtent => settingsRouteKey != null ? settings.getTileExtent(settingsRouteKey!) : _defaultExtent;

  set _settingsTileExtent(double v) {
    if (settingsRouteKey != null) settings.setTileExtent(settingsRouteKey!, v);
  }

  this {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$TileExtentController',
        object: this,
      );
    }
    // initialize extent to 0, so that it will be dynamically sized on first launch
    userPreferredExtent = _settingsTileExtent;
    if (settingsRouteKey != null) {
      _subscriptions.add(settings.updateTileExtentStream.listen((_) => _onSettingsChanged()));
    }
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    extentNotifier.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  void _onSettingsChanged() {
    if (userPreferredExtent != _settingsTileExtent) {
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
    final preferredExtent = userPreferredExtent ?? _settingsTileExtent;
    final targetExtent = preferredExtent > 0 ? preferredExtent : extentNotifier.value;

    final columnCount = _effectiveColumnCountForExtent(targetExtent);
    final newExtent = _extentForColumnCount(columnCount).clamp(effectiveExtentMin, effectiveExtentMax);

    if (this.userPreferredExtent != preferredExtent) {
      this.userPreferredExtent = preferredExtent;
      _settingsTileExtent = preferredExtent;
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
