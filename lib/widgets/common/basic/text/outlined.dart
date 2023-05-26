import 'dart:ui';

import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final List<TextSpan> textSpans;
  final double outlineWidth;
  final Color outlineColor;
  final double outlineBlurSigma;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  static const widgetSpanAlignment = PlaceholderAlignment.middle;

  const OutlinedText({
    super.key,
    required this.textSpans,
    double? outlineWidth,
    Color? outlineColor,
    double? outlineBlurSigma,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
  })  : outlineWidth = outlineWidth ?? 1,
        outlineColor = outlineColor ?? Colors.black,
        outlineBlurSigma = outlineBlurSigma ?? 0;

  @override
  Widget build(BuildContext context) {
    // TODO TLAD [subtitles] fix background area for mixed alphabetic-ideographic text
    // as of Flutter v3.10.0, the area computed for `backgroundColor` has inconsistent height
    // in case of mixed alphabetic-ideographic text. The painted boxes depend on the script.
    // Possible workarounds would be to use metrics from:
    // - `TextPainter.getBoxesForSelection`
    // - `Paragraph.getBoxesForRange`
    // and paint the background at the bottom of the `Stack`

    final hasOutline = outlineWidth > 0;

    Widget? outline;
    if (hasOutline) {
      outline = Text.rich(
        TextSpan(
          children: textSpans.map(_toStrokeSpan).toList(),
        ),
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: overflow,
        maxLines: maxLines,
      );
      if (outlineBlurSigma > 0) {
        outline = ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: outlineBlurSigma,
            sigmaY: outlineBlurSigma,
          ),
          child: outline,
        );
      }
    }

    final fill = Text.rich(
      TextSpan(
        children: hasOutline ? textSpans.map(_toFillSpan).toList() : textSpans,
      ),
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
    );

    return Stack(
      children: [
        if (outline != null) outline,
        fill,
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
          shadows: [],
        ),
      );
}
