import 'package:flutter/material.dart';

class AvesDot extends StatelessWidget {
  final double diameter, outerBorderWidth, innerBorderWidth;
  final Color Function(bool isDark) getOuterBorderColor, getInnerBorderColor;

  const AvesDot({
    super.key,
    this.diameter = 16,
    this.outerBorderWidth = 1.5,
    this.innerBorderWidth = 2,
    this.getOuterBorderColor = themedOuterBorderColor,
    this.getInnerBorderColor = themedInnerBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final outerBorderColor = getOuterBorderColor(isDark);
    final innerBorderColor = getInnerBorderColor(isDark);
    final outerBorderRadius = BorderRadius.all(Radius.circular(diameter));
    final innerRadius = Radius.circular(diameter - outerBorderWidth);
    final innerBorderRadius = BorderRadius.all(innerRadius);

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
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  static Color themedOuterBorderColor(bool isDark) => isDark ? Colors.white30 : Colors.black26;

  static Color themedInnerBorderColor(bool isDark) => isDark ? const Color(0xFF212121) : Colors.white;
}
