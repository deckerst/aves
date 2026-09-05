import 'package:material_ui/material_ui.dart';

enum MapNavigationButton { back, close, map, none }

class const MapThemeData({
  required final bool interactive,
  required final bool showCoordinateFilter,
  required final MapNavigationButton navigationButton,
  required final Animation<double> scale,
  required final VisualDensity visualDensity,
  required final double? mapHeight,
  required final EdgeInsets attributionPadding,
}) {
  double get buttonPadding => 8 + visualDensity.horizontal * 2;

  static const double markerOuterBorderWidth = 1.5;
  static const double markerInnerBorderWidth = 2;
  static const double markerImageExtent = 48.0;
  static const Size markerArrowSize = Size(8, 6);
  static const double markerDotDiameter = 16;
  static const int trackWidth = 5;

  static Color markerThemedOuterBorderColor(bool isDark) => isDark ? Colors.white30 : Colors.black26;

  static Color markerThemedInnerBorderColor(bool isDark) => isDark ? const Color(0xFF212121) : Colors.white;
}
