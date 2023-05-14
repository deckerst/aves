import 'package:flutter/material.dart';

class CheckeredPainter extends CustomPainter {
  final Paint lightPaint, darkPaint;
  final double checkSize;
  final Offset offset;

  CheckeredPainter({
    Color light = const Color(0xFF999999),
    Color dark = const Color(0xFF666666),
    this.checkSize = 20,
    this.offset = Offset.zero,
  })  : lightPaint = Paint()..color = light,
        darkPaint = Paint()..color = dark;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Offset.zero & size;
    canvas.drawRect(background, lightPaint);

    final dx = offset.dx % (checkSize * 2);
    final dy = offset.dy % (checkSize * 2);

    final xMax = (size.width / checkSize).ceil();
    final yMax = (size.height / checkSize).ceil();
    for (var x = -2; x < xMax; x++) {
      for (var y = -2; y < yMax; y++) {
        if ((x + y) % 2 == 0) {
          final check = Rect.fromLTWH(dx + x * checkSize, dy + y * checkSize, checkSize, checkSize);
          if (check.overlaps(background)) {
            canvas.drawRect(check.intersect(background), darkPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
