import 'package:aves/model/entry.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:custom_rounded_rectangle_border/custom_rounded_rectangle_border.dart';
import 'package:flutter/material.dart';

class ImageMarker extends StatelessWidget {
  final AvesEntry? entry;
  final int? count;
  final double extent;
  final Size arrowSize;
  final bool progressive;

  static const double outerBorderRadiusDim = 8;
  static const double outerBorderWidth = 1.5;
  static const double innerBorderWidth = 2;
  static const outerBorderColor = Colors.white30;
  static const innerBorderColor = Color(0xFF212121);
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerRadius = Radius.circular(outerBorderRadiusDim - outerBorderWidth);
  static const innerBorderRadius = BorderRadius.all(innerRadius);

  const ImageMarker({
    Key? key,
    required this.entry,
    required this.count,
    required this.extent,
    required this.arrowSize,
    required this.progressive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = entry != null
        ? ThumbnailImage(
            entry: entry!,
            extent: extent,
            progressive: progressive,
          )
        : const SizedBox();

    // need to be sized for the Google map marker generator
    child = SizedBox(
      width: extent,
      height: extent,
      child: child,
    );

    const outerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: outerBorderColor,
        width: outerBorderWidth,
      )),
      borderRadius: outerBorderRadius,
    );

    const innerDecoration = BoxDecoration(
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
      const borderSide = BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      );
      child = Stack(
        children: [
          child,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: const CustomRoundedRectangleBorder(
                leftSide: borderSide,
                rightSide: borderSide,
                topSide: borderSide,
                bottomSide: borderSide,
                topLeftCornerSide: borderSide,
                bottomRightCornerSide: borderSide,
                borderRadius: BorderRadius.only(
                  topLeft: innerRadius,
                  bottomRight: innerRadius,
                ),
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12),
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

class DotMarker extends StatelessWidget {
  const DotMarker({Key? key}) : super(key: key);

  static const double diameter = 16;
  static const double outerBorderRadiusDim = diameter;
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerRadius = Radius.circular(outerBorderRadiusDim - ImageMarker.outerBorderWidth);
  static const innerBorderRadius = BorderRadius.all(innerRadius);

  @override
  Widget build(BuildContext context) {
    const outerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: ImageMarker.outerBorderColor,
        width: ImageMarker.outerBorderWidth,
      )),
      borderRadius: outerBorderRadius,
    );

    const innerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: ImageMarker.innerBorderColor,
        width: ImageMarker.innerBorderWidth,
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
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
