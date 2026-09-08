import 'package:material_ui/material_ui.dart';

class const MarkerArrowPainter({
  required final Color color,
  required final Color outlineColor,
  required final double outlineWidth,
  required final Size size,
}) extends CustomPainter {
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
      Paint()..color = outlineColor,
    );

    canvas.translate(0, -outlineWidth.ceilToDouble());
    canvas.drawPath(
      Path()
        ..moveTo(bottomCenter.dx, bottomCenter.dy)
        ..lineTo(topRight.dx, topRight.dy)
        ..lineTo(topLeft.dx, topLeft.dy)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
