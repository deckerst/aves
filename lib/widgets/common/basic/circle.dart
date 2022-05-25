import 'dart:math';

import 'package:flutter/material.dart';

class CircularIndicator extends StatefulWidget {
  final double radius, lineWidth, percent;
  final Color background, foreground;
  final Widget center;

  const CircularIndicator({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.background,
    required this.foreground,
    required this.center,
  });

  @override
  State<CircularIndicator> createState() => _CircularIndicatorState();
}

class _CircularIndicatorState extends State<CircularIndicator> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Circle(
            radius: widget.radius,
            lineWidth: widget.lineWidth,
            percent: 1.0,
            color: widget.background,
          ),
          Circle(
            radius: widget.radius,
            lineWidth: widget.lineWidth,
            percent: widget.percent,
            color: widget.foreground,
          ),
          widget.center,
        ],
      ),
    );
  }
}

class Circle extends StatelessWidget {
  final double radius, lineWidth, percent;
  final Color color;

  const Circle({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(radius),
      painter: _CirclePainter(
        lineWidth: lineWidth,
        radius: radius - lineWidth / 2,
        color: color,
        percent: percent,
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double radius, lineWidth, percent;
  final Color color;

  const _CirclePainter({
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = lineWidth;

    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      0,
      2 * pi * percent,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
