import 'package:flutter/material.dart';

class HighlightDecoration extends Decoration {
  final Color color;

  const HighlightDecoration({@required this.color});

  @override
  _HighlightDecorationPainter createBoxPainter([VoidCallback onChanged]) {
    return _HighlightDecorationPainter(this, onChanged);
  }
}

class _HighlightDecorationPainter extends BoxPainter {
  final HighlightDecoration decoration;

  const _HighlightDecorationPainter(this.decoration, VoidCallback onChanged) : super(onChanged);

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
