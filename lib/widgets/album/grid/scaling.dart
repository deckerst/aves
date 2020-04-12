import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/grid/list_sliver.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/album/tile_extent_manager.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GridScaleGestureDetector extends StatefulWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> extentNotifier;
  final Size mqSize;
  final EdgeInsets mqPadding;
  final Widget child;

  const GridScaleGestureDetector({
    this.scrollableKey,
    @required this.extentNotifier,
    @required this.mqSize,
    @required this.mqPadding,
    @required this.child,
  });

  @override
  _GridScaleGestureDetectorState createState() => _GridScaleGestureDetectorState();
}

class _GridScaleGestureDetectorState extends State<GridScaleGestureDetector> {
  double _startExtent, _extentMin, _extentMax;
  ValueNotifier<double> _scaledExtentNotifier;
  OverlayEntry _overlayEntry;
  ThumbnailMetadata _metadata;
  RenderSliver _renderSliver;
  RenderViewport _renderViewport;

  ValueNotifier<double> get tileExtentNotifier => widget.extentNotifier;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        final scrollableContext = widget.scrollableKey.currentContext;
        final RenderBox scrollableBox = scrollableContext.findRenderObject();
        final result = BoxHitTestResult();
        scrollableBox.hitTest(result, position: details.localFocalPoint);

        // find `RenderObject`s at the gesture focal point
        final firstOf = <T>(BoxHitTestResult result) => result.path.firstWhere((el) => el.target is T, orElse: () => null)?.target as T;
        final renderMetaData = firstOf<RenderMetaData>(result);
        // abort if we cannot find an image to show on overlay
        if (renderMetaData == null) return;
        _renderSliver = firstOf<RenderSliver>(result);
        _renderViewport = firstOf<RenderViewport>(result);
        _metadata = renderMetaData.metaData;
        _startExtent = tileExtentNotifier.value;
        _scaledExtentNotifier = ValueNotifier(_startExtent);

        // not the same as `MediaQuery.size.width`, because of screen insets/padding
        final gridWidth = scrollableBox.size.width;
        _extentMin = gridWidth / (gridWidth / TileExtentManager.tileExtentMin).round();
        _extentMax = gridWidth / (gridWidth / TileExtentManager.extentMaxForSize(widget.mqSize)).round();
        final halfExtent = _startExtent / 2;
        final thumbnailCenter = renderMetaData.localToGlobal(Offset(halfExtent, halfExtent));
        _overlayEntry = OverlayEntry(
          builder: (context) {
            return ScaleOverlay(
              imageEntry: _metadata.entry,
              center: thumbnailCenter,
              gridWidth: gridWidth,
              scaledExtentNotifier: _scaledExtentNotifier,
            );
          },
        );
        Overlay.of(scrollableContext).insert(_overlayEntry);
      },
      onScaleUpdate: (details) {
        if (_scaledExtentNotifier == null) return;
        final s = details.scale;
        _scaledExtentNotifier.value = (_startExtent * s).clamp(_extentMin, _extentMax);
      },
      onScaleEnd: (details) {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
          _overlayEntry = null;
        }
        if (_scaledExtentNotifier == null) return;

        final oldExtent = tileExtentNotifier.value;
        // sanitize and update grid layout if necessary
        final newExtent = TileExtentManager.applyTileExtent(
          widget.mqSize,
          widget.mqPadding,
          tileExtentNotifier,
          newExtent: _scaledExtentNotifier.value,
        );
        _scaledExtentNotifier = null;
        if (newExtent == oldExtent) return;

        // TODO TLAD fix scroll to specific thumbnail with custom SliverList
        // scroll to show the focal point thumbnail at its new position
        final sliverClosure = _renderSliver;
        final viewportClosure = _renderViewport;
        final index = _metadata.index;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final scrollableContext = widget.scrollableKey.currentContext;
          final gridSize = (scrollableContext.findRenderObject() as RenderBox).size;
          final newColumnCount = gridSize.width / newExtent;
          final row = index ~/ newColumnCount;
          // `Scrollable.ensureVisible` only works on already rendered objects
          // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
          final scrollOffset = viewportClosure.scrollOffsetOf(sliverClosure, (row + 1) * newExtent - gridSize.height / 2);
          viewportClosure.offset.jumpTo(scrollOffset.clamp(.0, double.infinity));
        });
      },
      child: widget.child,
    );
  }
}

class ScaleOverlay extends StatefulWidget {
  final ImageEntry imageEntry;
  final Offset center;
  final double gridWidth;
  final ValueNotifier<double> scaledExtentNotifier;

  const ScaleOverlay({
    @required this.imageEntry,
    @required this.center,
    @required this.gridWidth,
    @required this.scaledExtentNotifier,
  });

  @override
  _ScaleOverlayState createState() => _ScaleOverlayState();
}

class _ScaleOverlayState extends State<ScaleOverlay> {
  bool _init = false;

  Offset get center => widget.center;

  double get gridWidth => widget.gridWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _init = true));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: IgnorePointer(
        child: AnimatedContainer(
          decoration: _init
              ? BoxDecoration(
                  gradient: RadialGradient(
                    center: FractionalOffset.fromOffsetAndSize(center, MediaQuery.of(context).size),
                    radius: 1,
                    colors: [
                      Colors.black,
                      Colors.black54,
                    ],
                  ),
                )
              : const BoxDecoration(
                  // provide dummy gradient to lerp to the other one during animation
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
          duration: const Duration(milliseconds: 200),
          child: ValueListenableBuilder<double>(
            valueListenable: widget.scaledExtentNotifier,
            builder: (context, extent, child) {
              // keep scaled thumbnail within the screen
              final xMin = MediaQuery.of(context).padding.left;
              final xMax = xMin + gridWidth;
              var dx = .0;
              if (center.dx - extent / 2 < xMin) {
                dx = xMin - (center.dx - extent / 2);
              } else if (center.dx + extent / 2 > xMax) {
                dx = xMax - (center.dx + extent / 2);
              }
              final clampedCenter = center.translate(dx, 0);

              return CustomPaint(
                painter: GridPainter(
                  center: clampedCenter,
                  extent: extent,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: clampedCenter.dx - extent / 2,
                      top: clampedCenter.dy - extent / 2,
                      child: Thumbnail(
                        entry: widget.imageEntry,
                        extent: extent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Offset center;
  final double extent;

  const GridPainter({
    @required this.center,
    @required this.extent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = Thumbnail.borderWidth
      ..shader = ui.Gradient.radial(
        center,
        size.width / 2,
        [
          Thumbnail.borderColor,
          Colors.transparent,
        ],
        [
          min(.5, 2 * extent / size.width),
          1,
        ],
      );
    final topLeft = center.translate(-extent / 2, -extent / 2);
    for (var i = -1; i <= 2; i++) {
      canvas.drawLine(Offset(0, topLeft.dy + extent * i), Offset(size.width, topLeft.dy + extent * i), paint);
      canvas.drawLine(Offset(topLeft.dx + extent * i, 0), Offset(topLeft.dx + extent * i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
