import 'package:flutter/material.dart';

class CheckeredDecoration extends Decoration {
  final Color light, dark;
  final double checkSize;
  final Offset offset;

  const CheckeredDecoration({
    this.light = const Color(0xFF999999),
    this.dark = const Color(0xFF666666),
    this.checkSize = 20,
    this.offset = Offset.zero,
  });

  @override
  _CheckeredDecorationPainter createBoxPainter([VoidCallback onChanged]) {
    return _CheckeredDecorationPainter(this, onChanged);
  }
}

class _CheckeredDecorationPainter extends BoxPainter {
  final CheckeredDecoration decoration;

  const _CheckeredDecorationPainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    var dx = offset.dx;
    var dy = offset.dy;

    final lightPaint = Paint()..color = decoration.light;
    final darkPaint = Paint()..color = decoration.dark;
    final checkSize = decoration.checkSize;

    // save/restore because of the clip
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(dx, dy, size.width, size.height));

    canvas.drawPaint(lightPaint);

    dx += decoration.offset.dx % (decoration.checkSize * 2);
    dy += decoration.offset.dy % (decoration.checkSize * 2);

    final xMax = size.width / checkSize;
    final yMax = size.height / checkSize;
    for (var x = -2; x < xMax; x++) {
      for (var y = -2; y < yMax; y++) {
        if ((x + y) % 2 == 0) {
          final rect = Rect.fromLTWH(dx + x * checkSize, dy + y * checkSize, checkSize, checkSize);
          canvas.drawRect(rect, darkPaint);
        }
      }
    }
    canvas.restore();
  }
}
