import 'dart:ui' as ui;

import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

// metadata to identify entry from RenderObject hit test during collection scaling
class ScalerMetadata<T> {
  final T item;

  const ScalerMetadata(this.item);
}

class GridScaleGestureDetector<T> extends StatefulWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final Widget Function(Offset center, double extent, Widget child)? gridBuilder;
  final Widget Function(T item, double extent) scaledBuilder;
  final Rect Function(BuildContext context, T item) getScaledItemTileRect;
  final void Function(T item) onScaled;
  final Widget child;

  const GridScaleGestureDetector({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    this.gridBuilder,
    required this.scaledBuilder,
    required this.getScaledItemTileRect,
    required this.onScaled,
    required this.child,
  });

  @override
  _GridScaleGestureDetectorState createState() => _GridScaleGestureDetectorState<T>();
}

class _GridScaleGestureDetectorState<T> extends State<GridScaleGestureDetector<T>> {
  double? _startExtent, _extentMin, _extentMax;
  bool _applyingScale = false;
  ValueNotifier<double>? _scaledExtentNotifier;
  OverlayEntry? _overlayEntry;
  ScalerMetadata<T>? _metadata;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // the gesture detector wrongly detects a new scaling gesture
        // when scaling ends and we apply the new extent, so we prevent this
        // until we scaled and scrolled to the tile in the new grid
        if (_applyingScale) return;
        final scrollableContext = widget.scrollableKey.currentContext!;
        final scrollableBox = scrollableContext.findRenderObject() as RenderBox;
        final result = BoxHitTestResult();
        scrollableBox.hitTest(result, position: details.localFocalPoint);

        // find `RenderObject`s at the gesture focal point
        U? firstOf<U>(BoxHitTestResult result) => result.path.firstWhereOrNull((el) => el.target is U)?.target as U?;
        final renderMetaData = firstOf<RenderMetaData>(result);
        // abort if we cannot find an image to show on overlay
        if (renderMetaData == null) return;
        _metadata = renderMetaData.metaData;
        _startExtent = renderMetaData.size.width;
        _scaledExtentNotifier = ValueNotifier(_startExtent!);

        // not the same as `MediaQuery.size.width`, because of screen insets/padding
        final gridWidth = scrollableBox.size.width;

        final tileExtentController = context.read<TileExtentController>();
        _extentMin = tileExtentController.effectiveExtentMin;
        _extentMax = tileExtentController.effectiveExtentMax;

        final halfExtent = _startExtent! / 2;
        final thumbnailCenter = renderMetaData.localToGlobal(Offset(halfExtent, halfExtent));
        _overlayEntry = OverlayEntry(
          builder: (context) => ScaleOverlay(
            builder: (extent) => widget.scaledBuilder(_metadata!.item, extent),
            center: thumbnailCenter,
            viewportWidth: gridWidth,
            gridBuilder: widget.gridBuilder,
            scaledExtentNotifier: _scaledExtentNotifier!,
          ),
        );
        Overlay.of(scrollableContext)!.insert(_overlayEntry!);
      },
      onScaleUpdate: (details) {
        if (_scaledExtentNotifier == null) return;
        final s = details.scale;
        _scaledExtentNotifier!.value = (_startExtent! * s).clamp(_extentMin!, _extentMax!);
      },
      onScaleEnd: (details) {
        if (_scaledExtentNotifier == null) return;
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }

        _applyingScale = true;
        final tileExtentController = context.read<TileExtentController>();
        final oldExtent = tileExtentController.extentNotifier.value;
        // sanitize and update grid layout if necessary
        final newExtent = tileExtentController.setUserPreferredExtent(_scaledExtentNotifier!.value);
        _scaledExtentNotifier = null;
        if (newExtent == oldExtent) {
          _applyingScale = false;
        } else {
          // scroll to show the focal point thumbnail at its new position
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            final entry = _metadata!.item;
            _scrollToItem(entry);
            // warning: posting `onScaled` in the next frame with `addPostFrameCallback`
            // would trigger only when the scrollable offset actually changes
            Future.delayed(Durations.collectionScalingCompleteNotificationDelay).then((_) => widget.onScaled(entry));
            _applyingScale = false;
          });
        }
      },
      child: GestureDetector(
        // Horizontal/vertical drag gestures are interpreted as scaling
        // if they are not handled by `onHorizontalDragStart`/`onVerticalDragStart`
        // at the scaling `GestureDetector` level, or handled beforehand down the widget tree.
        // Setting `onHorizontalDragStart`, `onVerticalDragStart`, and `onScaleStart`
        // all at once is not allowed, so we use another `GestureDetector` for that.
        onVerticalDragStart: (details) {},
        onHorizontalDragStart: (details) {},
        child: widget.child,
      ),
    );
  }

  // about scrolling & offset retrieval:
  // `Scrollable.ensureVisible` only works on already rendered objects
  // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
  // `RenderViewport.scrollOffsetOf` is a good alternative
  void _scrollToItem(T item) {
    final scrollableContext = widget.scrollableKey.currentContext!;
    final scrollableHeight = (scrollableContext.findRenderObject() as RenderBox).size.height;
    final tileRect = widget.getScaledItemTileRect(context, item);
    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = widget.appBarHeightNotifier.value;
    final scrollOffset = tileRect.top + (tileRect.height - scrollableHeight) / 2 + appBarHeight;

    final controller = PrimaryScrollController.of(context);
    if (controller != null) {
      final maxScrollExtent = controller.position.maxScrollExtent;
      controller.jumpTo(scrollOffset.clamp(.0, maxScrollExtent));
    }
  }
}

class ScaleOverlay extends StatefulWidget {
  final Widget Function(double extent) builder;
  final Offset center;
  final double viewportWidth;
  final ValueNotifier<double> scaledExtentNotifier;
  final Widget Function(Offset center, double extent, Widget child)? gridBuilder;

  const ScaleOverlay({
    required this.builder,
    required this.center,
    required this.viewportWidth,
    required this.scaledExtentNotifier,
    this.gridBuilder,
  });

  @override
  _ScaleOverlayState createState() => _ScaleOverlayState();
}

class _ScaleOverlayState extends State<ScaleOverlay> {
  bool _init = false;

  Offset get center => widget.center;

  double get gridWidth => widget.viewportWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() => _init = true));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(
        builder: (context) => IgnorePointer(
          child: AnimatedContainer(
            decoration: _init
                ? BoxDecoration(
                    gradient: RadialGradient(
                      center: FractionalOffset.fromOffsetAndSize(center, context.select<MediaQueryData, Size>((mq) => mq.size)),
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
                final xMin = context.select<MediaQueryData, double>((mq) => mq.padding.left);
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
                child = widget.gridBuilder?.call(clampedCenter, extent, child) ?? child;
                return child;
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Offset center;
  final double extent, spacing, borderWidth;
  final Radius borderRadius;
  final Color color;

  const GridPainter({
    required this.center,
    required this.extent,
    required this.spacing,
    required this.borderWidth,
    required this.borderRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = extent * 3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          color,
          Colors.transparent,
        ],
        [
          extent / radius,
          1,
        ],
      );

    final delta = extent + spacing;
    for (var i = -2; i <= 2; i++) {
      final dx = delta * i;
      for (var j = -2; j <= 2; j++) {
        if (i == 0 && j == 0) continue;
        final dy = delta * j;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center + Offset(dx, dy),
              width: extent,
              height: extent,
            ),
            borderRadius,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
