import 'dart:ui' as ui;

import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/behaviour/eager_scale_gesture_recognizer.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
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
  final TileLayout tileLayout;
  final double Function(double width) heightForWidth;
  final Widget Function(Offset center, Size tileSize, Widget child) gridBuilder;
  final Widget Function(T item, Size tileSize) scaledBuilder;
  final Object Function(T item)? highlightItem;
  final Widget child;

  const GridScaleGestureDetector({
    Key? key,
    required this.scrollableKey,
    required this.tileLayout,
    required this.heightForWidth,
    required this.gridBuilder,
    required this.scaledBuilder,
    this.highlightItem,
    required this.child,
  }) : super(key: key);

  @override
  _GridScaleGestureDetectorState createState() => _GridScaleGestureDetectorState<T>();
}

class _GridScaleGestureDetectorState<T> extends State<GridScaleGestureDetector<T>> {
  Size? _startSize;
  double? _extentMin, _extentMax;
  bool _applyingScale = false;
  ValueNotifier<Size>? _scaledSizeNotifier;
  OverlayEntry? _overlayEntry;
  ScalerMetadata<T>? _metadata;

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      // Horizontal/vertical drag gestures are interpreted as scaling
      // if they are not handled by `onHorizontalDragStart`/`onVerticalDragStart`
      // at the scaling `GestureDetector` level, or handled beforehand down the widget tree.
      // Setting `onHorizontalDragStart`, `onVerticalDragStart`, and `onScaleStart`
      // all at once is not allowed, so we use another `GestureDetector` for that.
      onVerticalDragStart: (details) {},
      onHorizontalDragStart: (details) {},
      child: widget.child,
    );

    // as of Flutter v2.5.3, `ScaleGestureRecognizer` does not work well
    // when combined with the `VerticalDragGestureRecognizer` inside a `GridView`,
    // so it is modified to eagerly accept the gesture
    // when multiple pointers are involved, and take priority over drag gestures.
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        EagerScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerScaleGestureRecognizer>(
          () => EagerScaleGestureRecognizer(debugOwner: this),
          (instance) {
            instance
              ..onStart = _onScaleStart
              ..onUpdate = _onScaleUpdate
              ..onEnd = _onScaleEnd
              ..dragStartBehavior = DragStartBehavior.start;
          },
        ),
      },
      child: child,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    // the gesture detector wrongly detects a new scaling gesture
    // when scaling ends and we apply the new extent, so we prevent this
    // until we scaled and scrolled to the tile in the new grid
    if (_applyingScale) return;

    final tileExtentController = context.read<TileExtentController>();

    final scrollableContext = widget.scrollableKey.currentContext!;
    final scrollableBox = scrollableContext.findRenderObject() as RenderBox;
    final renderMetaData = _getClosestRenderMetadata(
      box: scrollableBox,
      localFocalPoint: details.localFocalPoint,
      spacing: tileExtentController.spacing,
    );
    // abort if we cannot find an image to show on overlay
    if (renderMetaData == null) return;
    _metadata = renderMetaData.metaData;
    _startSize = renderMetaData.size;
    _scaledSizeNotifier = ValueNotifier(_startSize!);

    // not the same as `MediaQuery.size.width`, because of screen insets/padding
    final gridWidth = scrollableBox.size.width;

    _extentMin = tileExtentController.effectiveExtentMin;
    _extentMax = tileExtentController.effectiveExtentMax;

    final halfSize = _startSize! / 2;
    final tileCenter = renderMetaData.localToGlobal(Offset(halfSize.width, halfSize.height));
    _overlayEntry = OverlayEntry(
      builder: (context) => _ScaleOverlay(
        builder: (scaledTileSize) {
          late final double themeExtent;
          switch (widget.tileLayout) {
            case TileLayout.grid:
              themeExtent = scaledTileSize.width;
              break;
            case TileLayout.list:
              themeExtent = scaledTileSize.height;
              break;
          }
          return SizedBox.fromSize(
            size: scaledTileSize,
            child: GridTheme(
              extent: themeExtent,
              child: widget.scaledBuilder(_metadata!.item, scaledTileSize),
            ),
          );
        },
        tileLayout: widget.tileLayout,
        center: tileCenter,
        viewportWidth: gridWidth,
        gridBuilder: widget.gridBuilder,
        scaledSizeNotifier: _scaledSizeNotifier!,
      ),
    );
    Overlay.of(scrollableContext)!.insert(_overlayEntry!);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_scaledSizeNotifier == null) return;
    final s = details.scale;
    switch (widget.tileLayout) {
      case TileLayout.grid:
        final scaledWidth = (_startSize!.width * s).clamp(_extentMin!, _extentMax!);
        _scaledSizeNotifier!.value = Size(scaledWidth, widget.heightForWidth(scaledWidth));
        break;
      case TileLayout.list:
        final scaledHeight = (_startSize!.height * s).clamp(_extentMin!, _extentMax!);
        _scaledSizeNotifier!.value = Size(_startSize!.width, scaledHeight);
        break;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_scaledSizeNotifier == null) return;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _applyingScale = true;
    final tileExtentController = context.read<TileExtentController>();
    final oldExtent = tileExtentController.extentNotifier.value;
    // sanitize and update grid layout if necessary
    late final double preferredExtent;
    switch (widget.tileLayout) {
      case TileLayout.grid:
        preferredExtent = _scaledSizeNotifier!.value.width;
        break;
      case TileLayout.list:
        preferredExtent = _scaledSizeNotifier!.value.height;
        break;
    }
    final newExtent = tileExtentController.setUserPreferredExtent(preferredExtent);
    _scaledSizeNotifier = null;
    if (newExtent == oldExtent) {
      _applyingScale = false;
    } else {
      // scroll to show the focal point thumbnail at its new position
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final trackItem = _metadata!.item;
        final highlightItem = widget.highlightItem?.call(trackItem) ?? trackItem;
        context.read<HighlightInfo>().trackItem(trackItem, animate: false, highlightItem: highlightItem);
        _applyingScale = false;
      });
    }
  }

  RenderMetaData? _getClosestRenderMetadata({
    required RenderBox box,
    required Offset localFocalPoint,
    required double spacing,
  }) {
    var position = localFocalPoint;
    while (position.dx > 0 && position.dy > 0) {
      final result = BoxHitTestResult();
      box.hitTest(result, position: position);

      // find `RenderObject`s at the gesture focal point
      U? firstOf<U>(BoxHitTestResult result) => result.path.firstWhereOrNull((el) => el.target is U)?.target as U?;
      final renderMetaData = firstOf<RenderMetaData>(result);
      if (renderMetaData != null) return renderMetaData;
      position = position.translate(-spacing, -spacing);
    }
    return null;
  }
}

class _ScaleOverlay extends StatefulWidget {
  final Widget Function(Size scaledTileSize) builder;
  final TileLayout tileLayout;
  final Offset center;
  final double viewportWidth;
  final ValueNotifier<Size> scaledSizeNotifier;
  final Widget Function(Offset center, Size tileSize, Widget child) gridBuilder;

  const _ScaleOverlay({
    Key? key,
    required this.builder,
    required this.tileLayout,
    required this.center,
    required this.viewportWidth,
    required this.scaledSizeNotifier,
    required this.gridBuilder,
  }) : super(key: key);

  @override
  _ScaleOverlayState createState() => _ScaleOverlayState();
}

class _ScaleOverlayState extends State<_ScaleOverlay> {
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
            decoration: _buildBackgroundDecoration(context),
            duration: Durations.collectionScalingBackgroundAnimation,
            child: ValueListenableBuilder<Size>(
              valueListenable: widget.scaledSizeNotifier,
              builder: (context, scaledSize, child) {
                final width = scaledSize.width;
                final height = scaledSize.height;
                // keep scaled thumbnail within the screen
                final xMin = context.select<MediaQueryData, double>((mq) => mq.padding.left);
                final xMax = xMin + gridWidth;
                var dx = .0;
                if (center.dx - width / 2 < xMin) {
                  dx = xMin - (center.dx - width / 2);
                } else if (center.dx + width / 2 > xMax) {
                  dx = xMax - (center.dx + width / 2);
                }
                final clampedCenter = center.translate(dx, 0);

                var child = widget.builder(scaledSize);
                child = Stack(
                  children: [
                    Positioned(
                      left: clampedCenter.dx - width / 2,
                      top: clampedCenter.dy - height / 2,
                      child: DefaultTextStyle(
                        style: const TextStyle(),
                        child: child,
                      ),
                    ),
                  ],
                );
                child = widget.gridBuilder(clampedCenter, scaledSize, child);
                return child;
              },
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    late final Offset gradientCenter;
    switch (widget.tileLayout) {
      case TileLayout.grid:
        gradientCenter = center;
        break;
      case TileLayout.list:
        gradientCenter = Offset(0, center.dy);
        break;
    }

    return _init
        ? BoxDecoration(
            gradient: RadialGradient(
              center: FractionalOffset.fromOffsetAndSize(gradientCenter, context.select<MediaQueryData, Size>((mq) => mq.size)),
              radius: 1,
              colors: const [
                Colors.black,
                Colors.black54,
                // Colors.amber,
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
          );
  }
}

class GridPainter extends CustomPainter {
  final TileLayout tileLayout;
  final Offset tileCenter;
  final Size tileSize;
  final double spacing, borderWidth;
  final Radius borderRadius;
  final Color color;

  const GridPainter({
    required this.tileLayout,
    required this.tileCenter,
    required this.tileSize,
    required this.spacing,
    required this.borderWidth,
    required this.borderRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    late final Offset chipCenter;
    late final Size chipSize;
    late final int deltaColumn;
    late final Shader strokeShader;
    switch (tileLayout) {
      case TileLayout.grid:
        chipCenter = tileCenter;
        chipSize = tileSize;
        deltaColumn = 2;
        strokeShader = ui.Gradient.radial(
          tileCenter,
          chipSize.shortestSide * 2,
          [
            color,
            Colors.transparent,
          ],
          [
            .8,
            1,
          ],
        );
        break;
      case TileLayout.list:
        chipSize = Size.square(tileSize.shortestSide);
        chipCenter = Offset(chipSize.width / 2, tileCenter.dy);
        deltaColumn = 0;
        strokeShader = ui.Gradient.linear(
          tileCenter - Offset(0, chipSize.shortestSide * 3),
          tileCenter + Offset(0, chipSize.shortestSide * 3),
          [
            Colors.transparent,
            color,
            color,
            Colors.transparent,
          ],
          [
            0,
            .2,
            .8,
            1,
          ],
        );
        break;
    }
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = strokeShader;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(.25);

    final chipWidth = chipSize.width;
    final chipHeight = chipSize.height;

    final deltaX = tileSize.width + spacing;
    final deltaY = tileSize.height + spacing;
    for (var i = -deltaColumn; i <= deltaColumn; i++) {
      final dx = deltaX * i;
      for (var j = -2; j <= 2; j++) {
        if (i == 0 && j == 0) continue;
        final dy = deltaY * j;
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: chipCenter + Offset(dx, dy),
            width: chipWidth - borderWidth,
            height: chipHeight - borderWidth,
          ),
          borderRadius,
        );

        if ((i.abs() == 1 && j == 0) || (j.abs() == 1 && i == 0)) {
          canvas.drawRRect(rect, fillPaint);
        }
        canvas.drawRRect(rect, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
