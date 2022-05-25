import 'package:aves_map/src/theme.dart';
import 'package:custom_rounded_rectangle_border/custom_rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class ImageMarker extends StatelessWidget {
  final int? count;
  final Widget Function(double extent) buildThumbnailImage;

  static const double outerBorderRadiusDim = 8;
  static const outerBorderWidth = MapThemeData.markerOuterBorderWidth;
  static const innerBorderWidth = MapThemeData.markerInnerBorderWidth;
  static const extent = MapThemeData.markerImageExtent;
  static const arrowSize = MapThemeData.markerArrowSize;
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerRadius = Radius.circular(outerBorderRadiusDim - outerBorderWidth);
  static const innerBorderRadius = BorderRadius.all(innerRadius);

  const ImageMarker({
    super.key,
    required this.count,
    required this.buildThumbnailImage,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = buildThumbnailImage(extent);

    // need to be sized for the Google map marker generator
    child = SizedBox(
      width: extent,
      height: extent,
      child: child,
    );

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

    child = DecoratedBox(
      decoration: innerDecoration,
      position: DecorationPosition.foreground,
      child: ClipRRect(
        borderRadius: innerBorderRadius,
        child: child,
      ),
    );

    if (count != null) {
      final borderSide = BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      );
      child = Stack(
        children: [
          child,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            decoration: ShapeDecoration(
              color: theme.colorScheme.secondary,
              shape: Directionality.of(context) == TextDirection.rtl
                  ? CustomRoundedRectangleBorder(
                      leftSide: borderSide,
                      rightSide: borderSide,
                      topSide: borderSide,
                      bottomSide: borderSide,
                      topRightCornerSide: borderSide,
                      bottomLeftCornerSide: borderSide,
                      borderRadius: const BorderRadius.only(
                        topRight: innerRadius,
                        bottomLeft: innerRadius,
                      ),
                    )
                  : CustomRoundedRectangleBorder(
                      leftSide: borderSide,
                      rightSide: borderSide,
                      topSide: borderSide,
                      bottomSide: borderSide,
                      topLeftCornerSide: borderSide,
                      bottomRightCornerSide: borderSide,
                      borderRadius: const BorderRadius.only(
                        topLeft: innerRadius,
                        bottomRight: innerRadius,
                      ),
                    ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return CustomPaint(
      foregroundPainter: _MarkerArrowPainter(
        color: innerBorderColor,
        outlineColor: outerBorderColor,
        outlineWidth: outerBorderWidth,
        size: arrowSize,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: arrowSize.height),
        child: Container(
          decoration: outerDecoration,
          child: child,
        ),
      ),
    );
  }
}

class _MarkerArrowPainter extends CustomPainter {
  final Color color, outlineColor;
  final double outlineWidth;
  final Size size;

  const _MarkerArrowPainter({
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final triangleWidth = this.size.width;
    final triangleHeight = this.size.height;

    final bottomCenter = Offset(size.width / 2, size.height);
    final topLeft = bottomCenter + Offset(-triangleWidth / 2, -triangleHeight);
    final topRight = bottomCenter + Offset(triangleWidth / 2, -triangleHeight);

    canvas.drawPath(
        Path()
          ..moveTo(bottomCenter.dx, bottomCenter.dy)
          ..lineTo(topRight.dx, topRight.dy)
          ..lineTo(topLeft.dx, topLeft.dy)
          ..close(),
        Paint()..color = outlineColor);

    canvas.translate(0, -outlineWidth.ceilToDouble());
    canvas.drawPath(
        Path()
          ..moveTo(bottomCenter.dx, bottomCenter.dy)
          ..lineTo(topRight.dx, topRight.dy)
          ..lineTo(topLeft.dx, topLeft.dy)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
