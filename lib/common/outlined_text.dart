import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final double outlineWidth;
  final Color outlineColor;

  const OutlinedText(
    this.data, {
    Key key,
    this.style,
    @required this.outlineWidth,
    @required this.outlineColor,
  }) : super(key: key);

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
