import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class GridScaleGestureDetector extends StatefulWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> columnCountNotifier;
  final Widget child;

  const GridScaleGestureDetector({
    this.scrollableKey,
    @required this.columnCountNotifier,
    @required this.child,
  });

  @override
  _GridScaleGestureDetectorState createState() => _GridScaleGestureDetectorState();
}

class _GridScaleGestureDetectorState extends State<GridScaleGestureDetector> {
  double _start;
  ValueNotifier<double> _scaledCountNotifier;
  OverlayEntry _overlayEntry;
  ThumbnailMetadata _metadata;
  RenderSliver _renderSliver;
  RenderViewport _renderViewport;

  ValueNotifier<double> get countNotifier => widget.columnCountNotifier;

  static const columnCountMin = 2.0;
  static const columnCountMax = 8.0;

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
        _renderSliver = firstOf<RenderSliverStickyHeader>(result);
        _renderViewport = firstOf<RenderViewport>(result);
        _metadata = renderMetaData.metaData;
        _start = countNotifier.value;
        _scaledCountNotifier = ValueNotifier(_start);

        final gridWidth = scrollableBox.size.width;
        final halfExtent = gridWidth / _start / 2;
        final thumbnailCenter = renderMetaData.localToGlobal(Offset(halfExtent, halfExtent));
        _overlayEntry = OverlayEntry(
          builder: (context) {
            return ScaleOverlay(
              imageEntry: _metadata.entry,
              thumbnailCenter: thumbnailCenter,
              gridWidth: gridWidth,
              scaledCountNotifier: _scaledCountNotifier,
            );
          },
        );
        Overlay.of(scrollableContext).insert(_overlayEntry);
      },
      onScaleUpdate: (details) {
        if (_scaledCountNotifier == null) return;
        final s = details.scale;
        _scaledCountNotifier.value = (s <= 1 ? lerpDouble(_start * 2, _start, s) : lerpDouble(_start, _start / 2, s / 6)).clamp(columnCountMin, columnCountMax);
      },
      onScaleEnd: (details) {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
          _overlayEntry = null;
        }
        if (_scaledCountNotifier == null) return;

        final newColumnCount = _scaledCountNotifier.value.roundToDouble();
        _scaledCountNotifier = null;
        if (newColumnCount == countNotifier.value) return;

        // update grid layout
        countNotifier.value = newColumnCount;

        // scroll to show the focal point thumbnail at its new position
        final sliverClosure = _renderSliver;
        final viewportClosure = _renderViewport;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final scrollableContext = widget.scrollableKey.currentContext;
          final gridSize = (scrollableContext.findRenderObject() as RenderBox).size;
          final newExtent = gridSize.width / newColumnCount;
          final row = _metadata.index ~/ newColumnCount;
          // `Scrollable.ensureVisible` only works on already rendered objects
          // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
          final scrollOffset = viewportClosure.scrollOffsetOf(sliverClosure, (row + 1) * newExtent - gridSize.height / 2);
          viewportClosure.offset.jumpTo(scrollOffset);
        });
      },
      child: widget.child,
    );
  }
}

class ScaleOverlay extends StatefulWidget {
  final ImageEntry imageEntry;
  final Offset thumbnailCenter;
  final double gridWidth;
  final ValueNotifier<double> scaledCountNotifier;

  const ScaleOverlay({
    @required this.imageEntry,
    @required this.thumbnailCenter,
    @required this.gridWidth,
    @required this.scaledCountNotifier,
  });

  @override
  _ScaleOverlayState createState() => _ScaleOverlayState();
}

class _ScaleOverlayState extends State<ScaleOverlay> {
  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: IgnorePointer(
        child: AnimatedContainer(
          color: Colors.black54,
          duration: const Duration(milliseconds: 300),
          child: ValueListenableBuilder(
            valueListenable: widget.scaledCountNotifier,
            builder: (context, columnCount, child) {
              final extent = widget.gridWidth / columnCount;
              return Stack(
                children: [
                  Positioned(
                    left: widget.thumbnailCenter.dx - extent / 2,
                    top: widget.thumbnailCenter.dy - extent / 2,
                    child: Thumbnail(
                      entry: widget.imageEntry,
                      extent: extent,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
