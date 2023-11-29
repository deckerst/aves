import 'package:flutter/material.dart';

class HighlightDecoration extends Decoration {
  final Color color;

  const HighlightDecoration({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _HighlightDecorationPainter(this, onChanged);
  }
}

class _HighlightDecorationPainter extends BoxPainter {
  final HighlightDecoration decoration;

  const _HighlightDecorationPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final confHeight = size.height;
    final paintHeight = confHeight * .32;
    final rect = Rect.fromLTWH(offset.dx, offset.dy + size.height * .58, size.width, paintHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(paintHeight));
    final paint = Paint()..color = decoration.color;
    canvas.drawRRect(rrect, paint);
  }
}
