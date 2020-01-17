import 'package:flutter/material.dart';

class HighlightDecoration extends Decoration {
  final Color color;

  const HighlightDecoration({@required this.color});

  @override
  HighlightDecorationPainter createBoxPainter([VoidCallback onChanged]) {
    return HighlightDecorationPainter(this, onChanged);
  }
}

class HighlightDecorationPainter extends BoxPainter {
  final HighlightDecoration decoration;

  const HighlightDecorationPainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    final confHeight = size.height;
    final paintHeight = confHeight * .4;
    final rect = Rect.fromLTWH(offset.dx, offset.dy + confHeight - paintHeight, size.width, paintHeight);
    final paint = Paint()..color = decoration.color;
    canvas.drawRect(rect, paint);
  }
}
