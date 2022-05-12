import 'dart:math';

import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Minimap extends StatelessWidget {
  final ValueNotifier<ViewState> viewStateNotifier;

  static const Size minimapSize = Size(96, 96);

  const Minimap({
    super.key,
    required this.viewStateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<ViewState>(
        valueListenable: viewStateNotifier,
        builder: (context, viewState, child) {
          final viewportSize = viewState.viewportSize;
          final contentSize = viewState.contentSize;
          if (viewportSize == null || contentSize == null) return const SizedBox();
          return CustomPaint(
            painter: MinimapPainter(
              viewportSize: viewportSize,
              contentSize: contentSize,
              viewCenterOffset: viewState.position,
              viewScale: viewState.scale!,
              minimapBorderColor: Colors.white30,
            ),
            size: minimapSize,
          );
        },
      ),
    );
  }
}

class MinimapPainter extends CustomPainter {
  final Size contentSize, viewportSize;
  final Offset viewCenterOffset;
  final double viewScale;
  final Color minimapBorderColor, viewportBorderColor;

  const MinimapPainter({
    required this.viewportSize,
    required this.contentSize,
    required this.viewCenterOffset,
    required this.viewScale,
    this.minimapBorderColor = Colors.white,
    this.viewportBorderColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (contentSize.width <= 0 || contentSize.height <= 0) return;

    final viewSize = contentSize * viewScale;
    if (viewSize.isEmpty) return;

    // hide minimap when image is in full view
    if (viewportSize + const Offset(precisionErrorTolerance, precisionErrorTolerance) >= viewSize) return;

    final canvasScale = size.longestSide / viewSize.longestSide;
    final scaledContentSize = viewSize * canvasScale;
    final scaledViewportSize = viewportSize * canvasScale;

    final contentRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scaledContentSize.width,
      height: scaledContentSize.height,
    );
    final viewportRect = Rect.fromCenter(
      center: size.center(Offset.zero) - viewCenterOffset * canvasScale,
      width: min(scaledContentSize.width, scaledViewportSize.width),
      height: min(scaledContentSize.height, scaledViewportSize.height),
    );

    canvas.translate((contentRect.width - size.width) / 2, (contentRect.height - size.height) / 2);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x33000000);
    final minimapStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = minimapBorderColor;
    final viewportStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = viewportBorderColor;

    canvas.drawRect(viewportRect, fill);
    canvas.drawRect(contentRect, fill);
    canvas.drawRect(contentRect, minimapStroke);
    canvas.drawRect(viewportRect, viewportStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
