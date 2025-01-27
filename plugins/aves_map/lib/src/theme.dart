import 'package:flutter/material.dart';

enum MapNavigationButton { back, close, map, none }

class MapThemeData {
  final bool interactive, showCoordinateFilter;
  final MapNavigationButton navigationButton;
  final Animation<double> scale;
  final VisualDensity visualDensity;
  final double? mapHeight;
  final EdgeInsets attributionPadding;

  const MapThemeData({
    required this.interactive,
    required this.showCoordinateFilter,
    required this.navigationButton,
    required this.scale,
    required this.visualDensity,
    required this.mapHeight,
    required this.attributionPadding,
  });

  static const double markerOuterBorderWidth = 1.5;
  static const double markerInnerBorderWidth = 2;
  static const double markerImageExtent = 48.0;
  static const Size markerArrowSize = Size(8, 6);
  static const double markerDotDiameter = 16;
  static const int trackWidth = 5;

  static Color markerThemedOuterBorderColor(bool isDark) => isDark ? Colors.white30 : Colors.black26;

  static Color markerThemedInnerBorderColor(bool isDark) => isDark ? const Color(0xFF212121) : Colors.white;
}
