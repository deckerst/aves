import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double outlineWidth;
  final Color outlineColor;
  final TextAlign? textAlign;

  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  const OutlinedText({
    Key? key,
    required this.text,
    required this.style,
    double? outlineWidth,
    Color? outlineColor,
    this.textAlign,
  })  : outlineWidth = outlineWidth ?? 1,
        outlineColor = outlineColor ?? Colors.black,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text,
                style: style.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = outlineWidth
                    ..color = outlineColor,
                ),
              ),
            ],
          ),
          textAlign: textAlign,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text,
                style: style,
              ),
            ],
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}
