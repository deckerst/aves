import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Minimap extends StatelessWidget {
  final AvesEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final Size size;

  static const defaultSize = Size(96, 96);

  const Minimap({
    Key? key,
    required this.entry,
    required this.viewStateNotifier,
    this.size = defaultSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<ViewState>(
          valueListenable: viewStateNotifier,
          builder: (context, viewState, child) {
            final viewportSize = viewState.viewportSize;
            if (viewportSize == null) return const SizedBox.shrink();
            return AnimatedBuilder(
              animation: entry.imageChangeNotifier,
              builder: (context, child) {
                Widget _builder(Size displaySize) => CustomPaint(
                      painter: MinimapPainter(
                        viewportSize: viewportSize,
                        entrySize: displaySize,
                        viewCenterOffset: viewState.position,
                        viewScale: viewState.scale!,
                        minimapBorderColor: Colors.white30,
                      ),
                      size: size,
                    );

                if (entry.isVideo) {
                  final videoController = context.read<VideoConductor>().getController(entry);
                  if (videoController == null) return const SizedBox();
                  return ValueListenableBuilder<double>(
                    valueListenable: videoController.sarNotifier,
                    builder: (context, sar, child) {
                      return _builder(entry.videoDisplaySize(sar));
                    },
                  );
                }
                return _builder(entry.displaySize);
              },
            );
          }),
    );
  }
}

class MinimapPainter extends CustomPainter {
  final Size entrySize, viewportSize;
  final Offset viewCenterOffset;
  final double viewScale;
  final Color minimapBorderColor, viewportBorderColor;

  const MinimapPainter({
    required this.viewportSize,
    required this.entrySize,
    required this.viewCenterOffset,
    required this.viewScale,
    this.minimapBorderColor = Colors.white,
    this.viewportBorderColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entrySize.width <= 0 || entrySize.height <= 0) return;

    final viewSize = entrySize * viewScale;
    if (viewSize.isEmpty) return;

    // hide minimap when image is in full view
    if (viewportSize + const Offset(precisionErrorTolerance, precisionErrorTolerance) >= viewSize) return;

    final canvasScale = size.longestSide / viewSize.longestSide;
    final scaledEntrySize = viewSize * canvasScale;
    final scaledViewportSize = viewportSize * canvasScale;

    final entryRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scaledEntrySize.width,
      height: scaledEntrySize.height,
    );
    final viewportRect = Rect.fromCenter(
      center: size.center(Offset.zero) - viewCenterOffset * canvasScale,
      width: min(scaledEntrySize.width, scaledViewportSize.width),
      height: min(scaledEntrySize.height, scaledViewportSize.height),
    );

    canvas.translate((entryRect.width - size.width) / 2, (entryRect.height - size.height) / 2);

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
    canvas.drawRect(entryRect, fill);
    canvas.drawRect(entryRect, minimapStroke);
    canvas.drawRect(viewportRect, viewportStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
