import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  final Color color;

  const CompassPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = size.width * .3;
    final height = size.height * .4;

    final northTriangle = Path()
      ..moveTo(center.dx - base / 2, center.dy)
      ..lineTo(center.dx, center.dy - height)
      ..lineTo(center.dx + base / 2, center.dy)
      ..close();
    final southTriangle = Path()
      ..moveTo(center.dx - base / 2, center.dy)
      ..lineTo(center.dx + base / 2, center.dy)
      ..lineTo(center.dx, center.dy + height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(.6);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.7
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(northTriangle, fillPaint);
    canvas.drawPath(northTriangle, strokePaint);
    canvas.drawPath(southTriangle, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
