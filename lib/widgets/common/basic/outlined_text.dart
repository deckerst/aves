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
    super.key,
    required this.textSpans,
    double? outlineWidth,
    Color? outlineColor,
    double? outlineBlurSigma,
    this.textAlign,
  })  : outlineWidth = outlineWidth ?? 1,
        outlineColor = outlineColor ?? Colors.black,
        outlineBlurSigma = outlineBlurSigma ?? 0;

  @override
  Widget build(BuildContext context) {
    // TODO TLAD [subtitles] fix background area for mixed alphabetic-ideographic text
    // as of Flutter v2.2.2, the area computed for `backgroundColor` has inconsistent height
    // in case of mixed alphabetic-ideographic text. The painted boxes depends on the script.
    // Possible workarounds would be to use metrics from:
    // - `TextPainter.getBoxesForSelection`
    // - `Paragraph.getBoxesForRange`
    // and paint the background at the bottom of the `Stack`
    final hasOutline = outlineWidth > 0;
    return Stack(
      children: [
        if (hasOutline)
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
            children: hasOutline ? textSpans.map(_toFillSpan).toList() : textSpans,
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
            ..color = outlineColor
            ..strokeWidth = outlineWidth,
        ),
      );

  TextSpan _toFillSpan(TextSpan span) => TextSpan(
        text: span.text,
        children: span.children,
        style: (span.style ?? const TextStyle()).copyWith(
          backgroundColor: Colors.transparent,
        ),
      );
}
