import 'package:aves/model/highlight.dart';
import 'package:aves/widgets/common/behaviour/eager_scale_gesture_recognizer.dart';
import 'package:aves/widgets/common/grid/sections/fixed/scale_overlay.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/scale_overlay.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves_model/aves_model.dart';
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
  final TileBuilder<T> scaledItemBuilder;
  final MosaicItemBuilder mosaicItemBuilder;
  final Object Function(T item)? highlightItem;
  final Widget child;

  const GridScaleGestureDetector({
    super.key,
    required this.scrollableKey,
    required this.tileLayout,
    required this.heightForWidth,
    required this.gridBuilder,
    required this.scaledItemBuilder,
    required this.mosaicItemBuilder,
    this.highlightItem,
    required this.child,
  });

  @override
  State<GridScaleGestureDetector<T>> createState() => _GridScaleGestureDetectorState<T>();
}

class _GridScaleGestureDetectorState<T> extends State<GridScaleGestureDetector<T>> {
  Size? _startSize;
  double? _extentMin, _extentMax;
  bool _applyingScale = false;
  ValueNotifier<Size>? _scaledSizeNotifier;
  OverlayEntry? _overlayEntry;
  ScalerMetadata<T>? _metadata;

  TileLayout get tileLayout => widget.tileLayout;

  @override
  void dispose() {
    _scaledSizeNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestureSettings = MediaQuery.gestureSettingsOf(context);

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
              ..dragStartBehavior = DragStartBehavior.start
              ..gestureSettings = gestureSettings;
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
    final metadata = renderMetaData.metaData;
    if (metadata is! ScalerMetadata<T>) return;
    _metadata = metadata;

    switch (tileLayout) {
      case TileLayout.mosaic:
        _startSize = Size.square(tileExtentController.extentNotifier.value);
      case TileLayout.grid:
      case TileLayout.list:
        _startSize = renderMetaData.size;
    }
    _scaledSizeNotifier = ValueNotifier(_startSize!);

    // not the same as `MediaQuery` metrics, because of screen insets/padding
    final scrollViewRect = scrollableBox.localToGlobal(Offset.zero) & scrollableBox.size;
    final contentRect = scrollViewRect.deflate(tileExtentController.horizontalPadding);

    _extentMin = tileExtentController.effectiveExtentMin;
    _extentMax = tileExtentController.effectiveExtentMax;

    final halfSize = _startSize! / 2;
    switch (tileLayout) {
      case TileLayout.mosaic:
        _overlayEntry = OverlayEntry(
          builder: (context) => MosaicScaleOverlay(
            contentRect: contentRect,
            spacing: tileExtentController.spacing,
            extentMax: _extentMax!,
            scaledSizeNotifier: _scaledSizeNotifier!,
            itemBuilder: widget.mosaicItemBuilder,
          ),
        );
      case TileLayout.grid:
      case TileLayout.list:
        final tileCenter = renderMetaData.localToGlobal(Offset(halfSize.width, halfSize.height));
        _overlayEntry = OverlayEntry(
          builder: (context) => FixedExtentScaleOverlay(
            tileLayout: tileLayout,
            tileCenter: tileCenter,
            contentRect: contentRect,
            scaledSizeNotifier: _scaledSizeNotifier!,
            gridBuilder: widget.gridBuilder,
            builder: (scaledTileSize) => SizedBox.fromSize(
              size: scaledTileSize,
              child: GridTheme(
                extent: tileLayout == TileLayout.grid ? scaledTileSize.width : scaledTileSize.height,
                child: widget.scaledItemBuilder(_metadata!.item, scaledTileSize),
              ),
            ),
          ),
        );
    }
    Overlay.of(scrollableContext).insert(_overlayEntry!);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_scaledSizeNotifier == null) return;

    final s = details.scale;
    switch (tileLayout) {
      case TileLayout.mosaic:
      case TileLayout.grid:
        final scaledWidth = (_startSize!.width * s).clamp(_extentMin!, _extentMax!);
        _scaledSizeNotifier!.value = Size(scaledWidth, widget.heightForWidth(scaledWidth));
      case TileLayout.list:
        final scaledHeight = (_startSize!.height * s).clamp(_extentMin!, _extentMax!);
        _scaledSizeNotifier!.value = Size(_startSize!.width, scaledHeight);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_scaledSizeNotifier == null) return;

    final scaledSize = _scaledSizeNotifier!.value;
    _scaledSizeNotifier!.dispose();
    _scaledSizeNotifier = null;

    final overlayEntry = _overlayEntry;
    _overlayEntry = null;
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry.dispose();
    }

    _applyingScale = true;
    final tileExtentController = context.read<TileExtentController>();
    final oldExtent = tileExtentController.extentNotifier.value;
    // sanitize and update grid layout if necessary
    late final double preferredExtent;
    switch (tileLayout) {
      case TileLayout.mosaic:
      case TileLayout.grid:
        preferredExtent = scaledSize.width;
      case TileLayout.list:
        preferredExtent = scaledSize.height;
    }
    final newExtent = tileExtentController.setUserPreferredExtent(preferredExtent);
    if (newExtent == oldExtent) {
      _applyingScale = false;
    } else {
      // scroll to show the focal point thumbnail at its new position
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
