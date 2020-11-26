import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/tile_extent_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// metadata to identify entry from RenderObject hit test during collection scaling
class ScalerMetadata<T> {
  final T item;

  const ScalerMetadata(this.item);
}

class GridScaleGestureDetector<T> extends StatefulWidget {
  final TileExtentManager tileExtentManager;
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final Size viewportSize;
  final bool showScaledGrid;
  final Widget Function(T item, double extent) scaledBuilder;
  final Rect Function(BuildContext context, T item) getScaledItemTileRect;
  final void Function(T item) onScaled;
  final Widget child;

  const GridScaleGestureDetector({
    @required this.tileExtentManager,
    @required this.scrollableKey,
    @required this.appBarHeightNotifier,
    @required this.viewportSize,
    @required this.showScaledGrid,
    @required this.scaledBuilder,
    @required this.getScaledItemTileRect,
    @required this.onScaled,
    @required this.child,
  });

  @override
  _GridScaleGestureDetectorState createState() => _GridScaleGestureDetectorState<T>();
}

class _GridScaleGestureDetectorState<T> extends State<GridScaleGestureDetector<T>> {
  double _startExtent, _extentMin, _extentMax;
  bool _applyingScale = false;
  ValueNotifier<double> _scaledExtentNotifier;
  OverlayEntry _overlayEntry;
  ScalerMetadata<T> _metadata;

  TileExtentManager get tileExtentManager => widget.tileExtentManager;

  Size get viewportSize => widget.viewportSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        // if `onHorizontalDragStart` callback is not defined,
        // horizontal drag gestures are interpreted as scaling
      },
      onScaleStart: (details) {
        // the gesture detector wrongly detects a new scaling gesture
        // when scaling ends and we apply the new extent, so we prevent this
        // until we scaled and scrolled to the tile in the new grid
        if (_applyingScale) return;
        final scrollableContext = widget.scrollableKey.currentContext;
        final RenderBox scrollableBox = scrollableContext.findRenderObject();
        final result = BoxHitTestResult();
        scrollableBox.hitTest(result, position: details.localFocalPoint);

        // find `RenderObject`s at the gesture focal point
        U firstOf<U>(BoxHitTestResult result) => result.path.firstWhere((el) => el.target is U, orElse: () => null)?.target as U;
        final renderMetaData = firstOf<RenderMetaData>(result);
        // abort if we cannot find an image to show on overlay
        if (renderMetaData == null) return;
        _metadata = renderMetaData.metaData;
        _startExtent = renderMetaData.size.width;
        _scaledExtentNotifier = ValueNotifier(_startExtent);

        // not the same as `MediaQuery.size.width`, because of screen insets/padding
        final gridWidth = scrollableBox.size.width;

        _extentMin = tileExtentManager.getEffectiveExtentMin(viewportSize);
        _extentMax = tileExtentManager.getEffectiveExtentMax(viewportSize);

        final halfExtent = _startExtent / 2;
        final thumbnailCenter = renderMetaData.localToGlobal(Offset(halfExtent, halfExtent));
        _overlayEntry = OverlayEntry(
          builder: (context) => ScaleOverlay(
            builder: (extent) => widget.scaledBuilder(_metadata.item, extent),
            center: thumbnailCenter,
            gridWidth: gridWidth,
            scaledExtentNotifier: _scaledExtentNotifier,
            showScaledGrid: widget.showScaledGrid,
          ),
        );
        Overlay.of(scrollableContext).insert(_overlayEntry);
      },
      onScaleUpdate: (details) {
        if (_scaledExtentNotifier == null) return;
        final s = details.scale;
        _scaledExtentNotifier.value = (_startExtent * s).clamp(_extentMin, _extentMax);
      },
      onScaleEnd: (details) {
        if (_scaledExtentNotifier == null) return;
        if (_overlayEntry != null) {
          _overlayEntry.remove();
          _overlayEntry = null;
        }

        _applyingScale = true;
        final oldExtent = tileExtentManager.extentNotifier.value;
        // sanitize and update grid layout if necessary
        final newExtent = tileExtentManager.applyTileExtent(
          viewportSize: widget.viewportSize,
          userPreferredExtent: _scaledExtentNotifier.value,
        );
        _scaledExtentNotifier = null;
        if (newExtent == oldExtent) {
          _applyingScale = false;
        } else {
          // scroll to show the focal point thumbnail at its new position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final entry = _metadata.item;
            _scrollToItem(entry);
            // warning: posting `onScaled` in the next frame with `addPostFrameCallback`
            // would trigger only when the scrollable offset actually changes
            Future.delayed(Durations.collectionScalingCompleteNotificationDelay).then((_) => widget.onScaled?.call(entry));
            _applyingScale = false;
          });
        }
      },
      child: widget.child,
    );
  }

  // about scrolling & offset retrieval:
  // `Scrollable.ensureVisible` only works on already rendered objects
  // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
  // `RenderViewport.scrollOffsetOf` is a good alternative
  void _scrollToItem(T item) {
    final scrollableContext = widget.scrollableKey.currentContext;
    final scrollableHeight = (scrollableContext.findRenderObject() as RenderBox).size.height;
    final tileRect = widget.getScaledItemTileRect(context, item);
    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = widget.appBarHeightNotifier.value;
    final scrollOffset = tileRect.top + (tileRect.height - scrollableHeight) / 2 + appBarHeight;

    PrimaryScrollController.of(context)?.jumpTo(max(.0, scrollOffset));
  }
}

class ScaleOverlay extends StatefulWidget {
  final Widget Function(double extent) builder;
  final Offset center;
  final double gridWidth;
  final ValueNotifier<double> scaledExtentNotifier;
  final bool showScaledGrid;

  const ScaleOverlay({
    @required this.builder,
    @required this.center,
    @required this.gridWidth,
    @required this.scaledExtentNotifier,
    @required this.showScaledGrid,
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
              : BoxDecoration(
                  // provide dummy gradient to lerp to the other one during animation
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
          duration: Durations.collectionScalingBackgroundAnimation,
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

              var child = widget.builder(extent);
              child = Stack(
                children: [
                  Positioned(
                    left: clampedCenter.dx - extent / 2,
                    top: clampedCenter.dy - extent / 2,
                    child: DefaultTextStyle(
                      style: TextStyle(),
                      child: child,
                    ),
                  ),
                ],
              );
              if (widget.showScaledGrid) {
                child = CustomPaint(
                  painter: GridPainter(
                    center: clampedCenter,
                    extent: extent,
                  ),
                  child: child,
                );
              }
              return child;
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
      ..strokeWidth = DecoratedThumbnail.borderWidth
      ..shader = ui.Gradient.radial(
        center,
        size.width / 2,
        [
          DecoratedThumbnail.borderColor,
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
