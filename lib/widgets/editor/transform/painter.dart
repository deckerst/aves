import 'dart:ui';

import 'package:flutter/material.dart';

class CropperPainter extends CustomPainter {
  final Rect rect;
  final double gridOpacity;
  final int gridDivision;

  const CropperPainter({
    required this.rect,
    required this.gridOpacity,
    required this.gridDivision,
  });

  static const double handleLength = kMinInteractiveDimension / 3 - 4;
  static const double handleWidth = 3;
  static const double borderWidth = 1;
  static const double gridWidth = 1;

  static const cornerColor = Colors.white;
  static final borderColor = Colors.white.withAlpha((255.0 * .5).round());
  static final gridColor = Colors.white.withAlpha((255.0 * .5).round());

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = handleWidth
      ..color = cornerColor;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridWidth
      ..color = gridColor.withAlpha((255.0 * gridColor.opacity * gridOpacity).round());

    final xLeft = rect.left;
    final yTop = rect.top;
    final xRight = rect.right;
    final yBottom = rect.bottom;

    final gridLeft = xLeft + borderWidth / 2;
    final gridRight = xRight - borderWidth / 2;
    final yStep = (yBottom - yTop) / gridDivision;
    for (var i = 1; i < gridDivision; i++) {
      canvas.drawLine(
        Offset(gridLeft, yTop + i * yStep),
        Offset(gridRight, yTop + i * yStep),
        gridPaint,
      );
    }
    final gridTop = yTop + borderWidth / 2;
    final gridBottom = yBottom - borderWidth / 2;
    final xStep = (xRight - xLeft) / gridDivision;
    for (var i = 1; i < gridDivision; i++) {
      canvas.drawLine(
        Offset(xLeft + i * xStep, gridTop),
        Offset(xLeft + i * xStep, gridBottom),
        gridPaint,
      );
    }

    canvas.drawPoints(
        PointMode.polygon,
        [
          rect.topLeft.translate(0, handleLength),
          rect.topLeft,
          rect.topLeft.translate(handleLength, 0),
        ],
        cornerPaint);

    canvas.drawPoints(
        PointMode.polygon,
        [
          rect.topRight.translate(-handleLength, 0),
          rect.topRight,
          rect.topRight.translate(0, handleLength),
        ],
        cornerPaint);

    canvas.drawPoints(
        PointMode.polygon,
        [
          rect.bottomRight.translate(0, -handleLength),
          rect.bottomRight,
          rect.bottomRight.translate(-handleLength, 0),
        ],
        cornerPaint);

    canvas.drawPoints(
        PointMode.polygon,
        [
          rect.bottomLeft.translate(handleLength, 0),
          rect.bottomLeft,
          rect.bottomLeft.translate(0, -handleLength),
        ],
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScrimPainter extends CustomPainter {
  final Path excludePath;
  final double opacity;

  const ScrimPainter({
    required this.excludePath,
    required this.opacity,
  });

  static const double borderWidth = 1;

  static const scrimColor = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = scrimColor.withAlpha((255.0 * opacity).round());

    final outside = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height).inflate(.5))
      ..close();
    canvas.drawPath(Path.combine(PathOperation.difference, outside, excludePath), scrimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
