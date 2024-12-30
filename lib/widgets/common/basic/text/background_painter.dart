import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// as of Flutter v3.3.7, text style background does not have consistent height
// when rendering multi-script text, so we paint the background behind via a stack instead
class TextBackgroundPainter extends StatelessWidget {
  final List<TextSpan> spans;
  final TextStyle style;
  final TextAlign textAlign;
  final Widget child;

  const TextBackgroundPainter({
    super.key,
    required this.spans,
    required this.style,
    required this.textAlign,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = style.backgroundColor;
    if (backgroundColor == null || backgroundColor.a == 0) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final paragraph = RenderParagraph(
          TextSpan(
            children: spans,
            style: style,
          ),
          textAlign: textAlign,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(constraints, parentUsesSize: true);

        final textLength = spans.map((v) => v.text?.length ?? 0).sum;
        final allBoxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: textLength),
          boxHeightStyle: ui.BoxHeightStyle.max,
        );
        paragraph.dispose();

        // merge boxes to avoid artifacts at box edges, from anti-aliasing and rounding hacks
        final lineRects = groupBy<TextBox, double>(allBoxes, (v) => v.top).entries.map((kv) {
          final top = kv.key;
          final lineBoxes = kv.value;
          return Rect.fromLTRB(
            lineBoxes.map((v) => v.left).min,
            top,
            lineBoxes.map((v) => v.right).max,
            lineBoxes.first.bottom,
          );
        });

        return Stack(
          children: [
            ...lineRects.map((rect) {
              return Positioned.fromRect(
                rect: rect,
                child: ColoredBox(
                  color: backgroundColor,
                ),
              );
            }),
            child,
          ],
        );
      },
    );
  }
}
