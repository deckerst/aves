import 'package:aves/model/entry.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:custom_rounded_rectangle_border/custom_rounded_rectangle_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageMarker extends StatelessWidget {
  final AvesEntry? entry;
  final int? count;
  final double extent;
  final Size pointerSize;
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
    required this.pointerSize,
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

    // need to be sized for the Google Maps marker generator
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
      foregroundPainter: MarkerPointerPainter(
        color: innerBorderColor,
        outlineColor: outerBorderColor,
        outlineWidth: outerBorderWidth,
        size: pointerSize,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: pointerSize.height),
        child: Container(
          decoration: outerDecoration,
          child: child,
        ),
      ),
    );
  }
}

class MarkerPointerPainter extends CustomPainter {
  final Color color, outlineColor;
  final double outlineWidth;
  final Size size;

  const MarkerPointerPainter({
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointerWidth = this.size.width;
    final pointerHeight = this.size.height;

    final bottomCenter = Offset(size.width / 2, size.height);
    final topLeft = bottomCenter + Offset(-pointerWidth / 2, -pointerHeight);
    final topRight = bottomCenter + Offset(pointerWidth / 2, -pointerHeight);

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
