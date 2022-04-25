import 'package:aves_map/src/theme.dart';
import 'package:flutter/material.dart';

class DotMarker extends StatelessWidget {
  const DotMarker({Key? key}) : super(key: key);

  static const double diameter = 16;
  static const double outerBorderRadiusDim = diameter;
  static const double outerBorderWidth = MapThemeData.markerOuterBorderWidth;
  static const double innerBorderWidth = MapThemeData.markerInnerBorderWidth;
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerRadius = Radius.circular(outerBorderRadiusDim - outerBorderWidth);
  static const innerBorderRadius = BorderRadius.all(innerRadius);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final outerBorderColor = MapThemeData.markerThemedOuterBorderColor(isDark);
    final innerBorderColor = MapThemeData.markerThemedInnerBorderColor(isDark);

    final outerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: outerBorderColor,
        width: outerBorderWidth,
      )),
      borderRadius: outerBorderRadius,
    );

    final innerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      )),
      borderRadius: innerBorderRadius,
    );

    return Container(
      decoration: outerDecoration,
      child: DecoratedBox(
        decoration: innerDecoration,
        position: DecorationPosition.foreground,
        child: ClipRRect(
          borderRadius: innerBorderRadius,
          child: Container(
            width: diameter,
            height: diameter,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
