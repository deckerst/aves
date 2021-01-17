import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/widgets/viewer/multipage.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Minimap extends StatelessWidget {
  final ImageEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final MultiPageController multiPageController;
  final Size size;

  static const defaultSize = Size(96, 96);

  const Minimap({
    @required this.entry,
    @required this.viewStateNotifier,
    @required this.multiPageController,
    this.size = defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: multiPageController != null
          ? FutureBuilder<MultiPageInfo>(
              future: multiPageController.info,
              builder: (context, snapshot) {
                final multiPageInfo = snapshot.data;
                if (multiPageInfo == null) return SizedBox.shrink();
                return ValueListenableBuilder<int>(
                  valueListenable: multiPageController.pageNotifier,
                  builder: (context, page, child) {
                    return _buildForEntrySize(entry.getDisplaySize(multiPageInfo: multiPageInfo, page: page));
                  },
                );
              })
          : _buildForEntrySize(entry.getDisplaySize()),
    );
  }

  Widget _buildForEntrySize(Size entrySize) {
    return ValueListenableBuilder<ViewState>(
        valueListenable: viewStateNotifier,
        builder: (context, viewState, child) {
          final viewportSize = viewState.viewportSize;
          if (viewportSize == null) return SizedBox.shrink();
          return CustomPaint(
            painter: MinimapPainter(
              viewportSize: viewportSize,
              entrySize: entrySize,
              viewCenterOffset: viewState.position,
              viewScale: viewState.scale,
              minimapBorderColor: Colors.white30,
            ),
            size: size,
          );
        });
  }
}

class MinimapPainter extends CustomPainter {
  final Size entrySize, viewportSize;
  final Offset viewCenterOffset;
  final double viewScale;
  final Color minimapBorderColor, viewportBorderColor;

  const MinimapPainter({
    @required this.viewportSize,
    @required this.entrySize,
    @required this.viewCenterOffset,
    @required this.viewScale,
    this.minimapBorderColor = Colors.white,
    this.viewportBorderColor = Colors.white,
  })  : assert(viewportSize != null),
        assert(entrySize != null),
        assert(viewCenterOffset != null),
        assert(viewScale != null);

  @override
  void paint(Canvas canvas, Size size) {
    final viewSize = entrySize * viewScale;
    if (viewSize.isEmpty) return;

    // hide minimap when image is in full view
    if (viewportSize + Offset(precisionErrorTolerance, precisionErrorTolerance) >= viewSize) return;

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
      ..color = Color(0x33000000);
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
