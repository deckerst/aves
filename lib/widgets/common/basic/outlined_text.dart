import 'dart:ui';

import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final List<TextSpan> textSpans;
  final double outlineWidth;
  final Color outlineColor;
  final double outlineBlurSigma;
  final TextAlign? textAlign;

  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  const OutlinedText({
    Key? key,
    required this.textSpans,
    double? outlineWidth,
    Color? outlineColor,
    double? outlineBlurSigma,
    this.textAlign,
  })  : outlineWidth = outlineWidth ?? 1,
        outlineColor = outlineColor ?? Colors.black,
        outlineBlurSigma = outlineBlurSigma ?? 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: outlineBlurSigma > 0
              ? ImageFilter.blur(
                  sigmaX: outlineBlurSigma,
                  sigmaY: outlineBlurSigma,
                )
              : ImageFilter.matrix(
                  Matrix4.identity().storage,
                ),
          child: Text.rich(
            TextSpan(
              children: textSpans.map(_toStrokeSpan).toList(),
            ),
            textAlign: textAlign,
          ),
        ),
        Text.rich(
          TextSpan(
            children: textSpans,
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }

  TextSpan _toStrokeSpan(TextSpan span) => TextSpan(
        text: span.text,
        children: span.children,
        style: (span.style ?? const TextStyle()).copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = outlineWidth
            ..color = outlineColor,
        ),
      );
}
