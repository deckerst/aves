import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final double outlineWidth;
  final Color outlineColor;

  OutlinedText(
    this.data, {
    this.style,
    @required this.outlineWidth,
    @required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          data,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
          ),
        ),
        Text(
          data,
          style: style,
        ),
      ],
    );
  }
}
