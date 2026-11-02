import 'dart:math';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/enums/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:aves/widgets/viewer/visual/tiling.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class const RasterImageView({
  super.key,
  required final AvesEntry entry,
  required final ValueNotifier<ViewState> viewStateNotifier,
  required final double devicePixelRatio,
  required final ImageErrorWidgetBuilder errorBuilder,
}) extends StatefulWidget {
  @override
  State<RasterImageView> createState() => _RasterImageViewState();
}

class _RasterImageViewState extends State<RasterImageView> {
  Size? _viewportSize;
  RasterTiling? _tiling;
  ImageStream? _fullImageStream;
  late ImageStreamListener _fullImageListener;
  final ValueNotifier<bool> _fullImageLoaded = ValueNotifier(false);
  ImageInfo? _fullImageInfo;

  static const int _pixelArtMaxSize = 256; // px

  AvesEntry get entry => widget.entry;

  ImageProvider get thumbnailProvider => entry.bestCachedThumbnail;

  ImageProvider get fullImageProvider {
    if (entry.useTiles) {
      assert(_tiling != null);
      return entry.getRegion(
        sampleSize: _tiling!.maxSampleSize,
        region: entry.fullImageRegion,
      );
    } else {
      return entry.getFullImage();
    }
  }

  @override
  void initState() {
    super.initState();
    _fullImageListener = ImageStreamListener(_onFullImageCompleted);
    _viewportSize = widget.viewStateNotifier.value.viewportSize;
    _registerWidget(widget);
    _initFullImage();
  }

  @override
  void didUpdateWidget(covariant RasterImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);

    final oldViewState = oldWidget.viewStateNotifier.value;
    final viewState = widget.viewStateNotifier.value;
    if (oldWidget.entry != widget.entry || oldViewState.viewportSize != viewState.viewportSize || oldWidget.devicePixelRatio != widget.devicePixelRatio) {
      _initFullImage();
    }
  }

  void _initFullImage() {
    if (widget.entry.useTiles) {
      _onTilingSpecsChanged();
    } else {
      _unregisterFullImage();
      _registerFullImage();
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _fullImageLoaded.dispose();
    _unregisterFullImage();
    super.dispose();
  }

  void _registerWidget(RasterImageView widget) {
    widget.viewStateNotifier.addListener(_onViewStateChanged);
  }

  void _unregisterWidget(RasterImageView widget) {
    widget.viewStateNotifier.removeListener(_onViewStateChanged);
  }

  void _onViewStateChanged() {
    final viewportSize = widget.viewStateNotifier.value.viewportSize;
    if (_viewportSize != viewportSize) {
      _viewportSize = viewportSize;
      _onTilingSpecsChanged();
    }
  }

  void _onTilingSpecsChanged() {
    _tiling = null;

    final viewportSize = _viewportSize;
    if (viewportSize == null || viewportSize.isEmpty) return;

    if (entry.useTiles) {
      _tiling = RasterTiling.forEntry(
        devicePixelRatio: widget.devicePixelRatio,
        viewportSize: viewportSize,
        entry: entry,
      );
      _unregisterFullImage();
      _registerFullImage();
    }
  }

  void _registerFullImage() {
    _fullImageStream = fullImageProvider.resolve(ImageConfiguration.empty);
    _fullImageStream!.addListener(_fullImageListener);
    _fullImageLoaded.value = false;
  }

  void _unregisterFullImage() {
    _fullImageStream?.removeListener(_fullImageListener);
    _fullImageStream = null;
    _fullImageInfo?.dispose();
    _fullImageInfo = null;
    _fullImageLoaded.value = false;
  }

  // implementer is responsible for disposing the provided `ImageInfo`
  void _onFullImageCompleted(ImageInfo image, bool synchronousCall) {
    _fullImageInfo = image;
    _fullImageLoaded.value = true;
    FullImageLoadedNotification(entry, fullImageProvider).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewState>(
      valueListenable: widget.viewStateNotifier,
      builder: (context, viewState, child) {
        final magnifierScale = viewState.scale!;
        return SizedBox.fromSize(
          size: entry.displaySize * magnifierScale,
          child: Stack(
            alignment: .center,
            children: [
              if (entry.canHaveAlpha) ?_buildBackground(viewState),
              _buildLoading(),
              if (entry.useTiles) ..._buildTiles(viewState) else _buildFullImage(viewState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullImage(ViewState viewState) {
    final magnifierScale = viewState.scale!;
    final devicePixelRatio = widget.devicePixelRatio;
    final quality = _qualityForScaleAndSize(
      magnifierScale: magnifierScale,
      sampleSize: 1,
      devicePixelRatio: devicePixelRatio,
    );
    return Image(
      image: fullImageProvider,
      gaplessPlayback: true,
      errorBuilder: widget.errorBuilder,
      width: (entry.displaySize * magnifierScale).width,
      fit: BoxFit.contain,
      filterQuality: quality,
    );
  }

  Widget _buildLoading() {
    return ValueListenableBuilder<bool>(
      valueListenable: _fullImageLoaded,
      builder: (context, fullImageLoaded, child) {
        if (fullImageLoaded) return const SizedBox();

        return Center(
          child: AspectRatio(
            // enforce original aspect ratio, as some thumbnails aspect ratios slightly differ
            aspectRatio: entry.displayAspectRatio,
            child: Image(
              image: thumbnailProvider,
              fit: BoxFit.fill,
            ),
          ),
        );
      },
    );
  }

  Widget? _buildBackground(ViewState viewState) {
    final viewportSize = _viewportSize;
    if (viewportSize == null || viewportSize.isEmpty) return null;

    final viewSize = entry.displaySize * viewState.scale!;
    final decorationOffset = ((viewSize - viewportSize) as Offset) / 2 - viewState.position;
    // deflate as a quick way to prevent background bleed
    final decorationSize = (applyBoxFit(BoxFit.none, viewSize, viewportSize).source - const Offset(.5, .5)) as Size;

    Widget child;
    final background = settings.imageBackground;
    if (background == EntryBackground.checkered) {
      final side = viewportSize.shortestSide;
      final checkSize = side / ((side / EntryPageView.decorationCheckSize).round());
      final offset = ((decorationSize - viewportSize) as Offset) / 2;
      child = ValueListenableBuilder<bool>(
        valueListenable: _fullImageLoaded,
        builder: (context, fullImageLoaded, child) {
          if (!fullImageLoaded) return const SizedBox();

          return CustomPaint(
            painter: CheckeredPainter(
              checkSize: checkSize,
              offset: offset,
            ),
          );
        },
      );
    } else {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: background.color,
        ),
      );
    }
    return Positioned(
      left: decorationOffset.dx >= 0 ? decorationOffset.dx : null,
      top: decorationOffset.dy >= 0 ? decorationOffset.dy : null,
      width: decorationSize.width,
      height: decorationSize.height,
      child: child,
    );
  }

  List<Widget> _buildTiles(ViewState viewState) {
    final tiling = _tiling;
    if (tiling == null) return [];

    final maxSampleSize = tiling.maxSampleSize;
    final tileSide = tiling.tileSide;

    final displaySize = entry.displaySize;
    final displayWidth = displaySize.width.round();
    final displayHeight = displaySize.height.round();
    final viewRect = _getViewRect(viewState, displayWidth, displayHeight);
    final magnifierScale = viewState.scale!;
    final devicePixelRatio = widget.devicePixelRatio;

    // for the largest sample size (matching the initial scale), the whole image is in view
    // so we subsample the whole image without tiling
    final fullImageRegionTile = _RegionTile(
      entry: entry,
      tileRect: Rect.fromLTWH(0, 0, displayWidth * magnifierScale, displayHeight * magnifierScale),
      regionRect: entry.fullImageRegion,
      sampleSize: maxSampleSize,
      quality: _qualityForScaleAndSize(
        magnifierScale: magnifierScale,
        sampleSize: maxSampleSize,
        devicePixelRatio: devicePixelRatio,
      ),
    );
    final tiles = [fullImageRegionTile];

    final minSampleSize = min(ExtraAvesEntryImages.sampleSizeForScale(magnifierScale: magnifierScale, devicePixelRatio: devicePixelRatio), maxSampleSize);
    int nextSampleSize(int sampleSize) => (sampleSize / 2).floor();
    for (var sampleSize = nextSampleSize(maxSampleSize); sampleSize >= minSampleSize; sampleSize = nextSampleSize(sampleSize)) {
      final regionSide = (tileSide * sampleSize).round();
      for (var x = 0; x < displayWidth; x += regionSide) {
        for (var y = 0; y < displayHeight; y += regionSide) {
          final rects = _getTileRects(
            x: x,
            y: y,
            regionSide: regionSide,
            displayWidth: displayWidth,
            displayHeight: displayHeight,
            scale: magnifierScale,
            viewRect: viewRect,
          );
          if (rects != null) {
            final (tileRect, regionRect) = rects;
            tiles.add(
              _RegionTile(
                entry: entry,
                tileRect: tileRect,
                regionRect: regionRect,
                sampleSize: sampleSize,
                quality: _qualityForScaleAndSize(
                  magnifierScale: magnifierScale,
                  sampleSize: sampleSize,
                  devicePixelRatio: devicePixelRatio,
                ),
              ),
            );
          }
        }
      }
    }
    return tiles;
  }

  Rect _getViewRect(ViewState viewState, int displayWidth, int displayHeight) {
    final scale = viewState.scale!;
    final centerOffset = viewState.position;
    final viewportSize = _viewportSize!;
    final viewOrigin = Offset(
      ((displayWidth * scale - viewportSize.width) / 2 - centerOffset.dx),
      ((displayHeight * scale - viewportSize.height) / 2 - centerOffset.dy),
    );
    return viewOrigin & viewportSize;
  }

  (Rect tileRect, Rectangle<num> regionRect)? _getTileRects({
    required int x,
    required int y,
    required int regionSide,
    required int displayWidth,
    required int displayHeight,
    required double scale,
    required Rect viewRect,
  }) {
    final nextX = x + regionSide;
    final nextY = y + regionSide;
    final thisRegionWidth = regionSide - (nextX >= displayWidth ? nextX - displayWidth : 0);
    final thisRegionHeight = regionSide - (nextY >= displayHeight ? nextY - displayHeight : 0);
    final tileRect = Rect.fromLTWH(x * scale, y * scale, thisRegionWidth * scale, thisRegionHeight * scale);

    // only build visible tiles
    if (!viewRect.overlaps(tileRect)) return null;

    Rectangle<num> regionRect;
    final tileTransform = _tiling?.tileTransform;
    if (tileTransform != null) {
      // apply EXIF orientation
      final regionRectDouble = Rect.fromLTWH(x.toDouble(), y.toDouble(), thisRegionWidth.toDouble(), thisRegionHeight.toDouble());
      final tl = MatrixUtils.transformPoint(tileTransform, regionRectDouble.topLeft);
      final br = MatrixUtils.transformPoint(tileTransform, regionRectDouble.bottomRight);
      regionRect = Rectangle<double>.fromPoints(
        Point<double>(tl.dx, tl.dy),
        Point<double>(br.dx, br.dy),
      );
    } else {
      regionRect = Rectangle<num>(x, y, thisRegionWidth, thisRegionHeight);
    }
    return (tileRect, regionRect);
  }

  // follow recommended thresholds from `FilterQuality` documentation
  static FilterQuality _qualityForScale({
    required double magnifierScale,
    required int sampleSize,
    required double devicePixelRatio,
  }) {
    final entryScale = magnifierScale * devicePixelRatio;
    final renderingScale = entryScale * sampleSize;
    if (renderingScale > 1) {
      return renderingScale > 10 ? FilterQuality.high : FilterQuality.medium;
    } else {
      return renderingScale < .5 ? FilterQuality.medium : FilterQuality.high;
    }
  }

  // usually follow recommendations, except for small images
  // (like icons, pixel art, etc.) for which the "nearest neighbor" algorithm is used
  FilterQuality _qualityForScaleAndSize({
    required double magnifierScale,
    required int sampleSize,
    required double devicePixelRatio,
  }) {
    if (entry.displaySize.longestSide < _pixelArtMaxSize) {
      return FilterQuality.none;
    }

    return _qualityForScale(
      magnifierScale: magnifierScale,
      sampleSize: sampleSize,
      devicePixelRatio: devicePixelRatio,
    );
  }
}

class const _RegionTile({
  required final AvesEntry entry,
  // `tileRect` uses Flutter view coordinates
  required final Rect tileRect,
  // `regionRect` uses the raw image pixel coordinates
  required final Rectangle<num> regionRect,
  required final int sampleSize,
  required final FilterQuality quality,
}) extends StatefulWidget {
  @override
  State<_RegionTile> createState() => _RegionTileState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('id', entry.id));
    properties.add(IntProperty('contentId', entry.contentId));
    properties.add(DiagnosticsProperty<Rect>('tileRect', tileRect));
    properties.add(DiagnosticsProperty<Rectangle<num>>('regionRect', regionRect));
    properties.add(IntProperty('sampleSize', sampleSize));
  }
}

class _RegionTileState extends State<_RegionTile> {
  late RegionProvider _provider;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant _RegionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry || oldWidget.tileRect != widget.tileRect || oldWidget.sampleSize != widget.sampleSize || oldWidget.sampleSize != widget.sampleSize) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(_RegionTile widget) {
    _initProvider();
  }

  void _unregisterWidget(_RegionTile widget) {
    _pauseProvider();
  }

  void _initProvider() {
    _provider = entry.getRegion(
      sampleSize: widget.sampleSize,
      region: widget.regionRect,
    );
  }

  void _pauseProvider() => _provider.pause();

  @override
  Widget build(BuildContext context) {
    final tileRect = widget.tileRect;

    Widget child = Image(
      image: _provider,
      width: tileRect.width,
      height: tileRect.height,
      fit: BoxFit.fill,
      filterQuality: widget.quality,
    );

    // apply EXIF orientation
    final quarterTurns = entry.rotationDegrees ~/ 90;
    if (entry.isFlipped) {
      final rotated = quarterTurns % 2 != 0;
      final w = (rotated ? tileRect.height : tileRect.width) / 2.0;
      final h = (rotated ? tileRect.width : tileRect.height) / 2.0;
      final flipper = Matrix4.identity()
        ..translateByDouble(w, h, 0, 1)
        ..scaleByDouble(-1.0, 1.0, 1.0, 1.0)
        ..translateByDouble(-w, -h, 0, 1);
      child = Transform(
        transform: flipper,
        child: child,
      );
    }
    if (quarterTurns != 0) {
      child = RotatedBox(
        quarterTurns: quarterTurns,
        child: child,
      );
    }

    if (settings.debugShowViewerTiles) {
      final regionRect = widget.regionRect;
      child = Stack(
        children: [
          Positioned.fill(child: child),
          Text(
            '\ntile=(${tileRect.left.round()}, ${tileRect.top.round()}) ${tileRect.width.round()} x ${tileRect.height.round()}'
            '\nregion=(${regionRect.left.round()}, ${regionRect.top.round()}) ${regionRect.width.round()} x ${regionRect.height.round()}'
            '\nsampling=${widget.sampleSize} quality=${widget.quality.name}',
            style: const TextStyle(backgroundColor: Colors.black87),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
              ),
            ),
          ),
        ],
      );
    }

    return Positioned.fromRect(
      rect: tileRect,
      child: child,
    );
  }
}
