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
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RasterImageView extends StatefulWidget {
  final AvesEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final ImageErrorWidgetBuilder errorBuilder;

  const RasterImageView({
    super.key,
    required this.entry,
    required this.viewStateNotifier,
    required this.errorBuilder,
  });

  @override
  State<RasterImageView> createState() => _RasterImageViewState();
}

class _RasterImageViewState extends State<RasterImageView> {
  late Size _displaySize;
  late bool _useTiles;
  bool _isTilingInitialized = false;
  late int _maxSampleSize;
  late double _tileSide;
  Matrix4? _tileTransform;
  ImageStream? _fullImageStream;
  late ImageStreamListener _fullImageListener;
  final ValueNotifier<bool> _fullImageLoaded = ValueNotifier(false);
  ImageInfo? _fullImageInfo;

  static const int _pixelArtMaxSize = 256; // px
  static const double _tilesByShortestSide = 2;

  AvesEntry get entry => widget.entry;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  ViewState get viewState => viewStateNotifier.value;

  ImageProvider get thumbnailProvider => entry.bestCachedThumbnail;

  ImageProvider get fullImageProvider {
    if (_useTiles) {
      assert(_isTilingInitialized);
      return entry.getRegion(
        sampleSize: _maxSampleSize,
        region: entry.fullImageRegion,
      );
    } else {
      return entry.fullImage;
    }
  }

  @override
  void initState() {
    super.initState();
    _displaySize = entry.displaySize;
    _useTiles = entry.useTiles;
    _fullImageListener = ImageStreamListener(_onFullImageCompleted);
    if (!_useTiles) _registerFullImage();
  }

  @override
  void didUpdateWidget(covariant RasterImageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldViewState = oldWidget.viewStateNotifier.value;
    final viewState = widget.viewStateNotifier.value;
    if (oldWidget.entry != widget.entry || oldViewState.viewportSize != viewState.viewportSize) {
      _isTilingInitialized = false;
      _fullImageLoaded.value = false;
      _unregisterFullImage();
    }
  }

  @override
  void dispose() {
    _fullImageLoaded.dispose();
    _unregisterFullImage();
    super.dispose();
  }

  void _registerFullImage() {
    _fullImageStream = fullImageProvider.resolve(ImageConfiguration.empty);
    _fullImageStream!.addListener(_fullImageListener);
  }

  void _unregisterFullImage() {
    _fullImageStream?.removeListener(_fullImageListener);
    _fullImageStream = null;
    _fullImageInfo?.dispose();
  }

  void _onFullImageCompleted(ImageInfo image, bool synchronousCall) {
    // implementer is responsible for disposing the provided `ImageInfo`
    _unregisterFullImage();
    _fullImageInfo = image;
    _fullImageLoaded.value = true;
    FullImageLoadedNotification(entry, fullImageProvider).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewState>(
      valueListenable: viewStateNotifier,
      builder: (context, viewState, child) {
        final viewportSize = viewState.viewportSize;
        final viewportSized = viewportSize?.isEmpty == false;
        if (viewportSized && _useTiles && !_isTilingInitialized) _initTiling(viewportSize!);

        final magnifierScale = viewState.scale!;
        return SizedBox.fromSize(
          size: _displaySize * magnifierScale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (entry.canHaveAlpha && viewportSized) _buildBackground(),
              _buildLoading(),
              if (_useTiles) ..._buildTiles() else _buildFullImage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullImage() {
    final magnifierScale = viewState.scale!;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final quality = _qualityForScaleAndSize(
      magnifierScale: magnifierScale,
      sampleSize: 1,
      devicePixelRatio: devicePixelRatio,
    );
    return Image(
      image: fullImageProvider,
      gaplessPlayback: true,
      errorBuilder: widget.errorBuilder,
      width: (_displaySize * magnifierScale).width,
      fit: BoxFit.contain,
      filterQuality: quality,
    );
  }

  void _initTiling(Size viewportSize) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    _tileSide = viewportSize.shortestSide * devicePixelRatio / _tilesByShortestSide;
    // scale for initial state `contained`
    final containedScale = min(viewportSize.width / _displaySize.width, viewportSize.height / _displaySize.height);
    _maxSampleSize = ExtraAvesEntryImages.sampleSizeForScale(magnifierScale: containedScale, devicePixelRatio: devicePixelRatio);

    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;
    _tileTransform = null;
    if (rotationDegrees != 0 || isFlipped) {
      _tileTransform = Matrix4.identity()
        ..translate(entry.width / 2.0, entry.height / 2.0)
        ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
        ..rotateZ(-degToRadian(rotationDegrees.toDouble()))
        ..translate(-_displaySize.width / 2.0, -_displaySize.height / 2.0);
    }
    _isTilingInitialized = true;
    _registerFullImage();
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

  Widget _buildBackground() {
    final viewportSize = viewState.viewportSize!;
    final viewSize = _displaySize * viewState.scale!;
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

  List<Widget> _buildTiles() {
    if (!_isTilingInitialized) return [];

    final displayWidth = _displaySize.width.round();
    final displayHeight = _displaySize.height.round();
    final viewRect = _getViewRect(displayWidth, displayHeight);
    final magnifierScale = viewState.scale!;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // for the largest sample size (matching the initial scale), the whole image is in view
    // so we subsample the whole image without tiling
    final fullImageRegionTile = _RegionTile(
      entry: entry,
      tileRect: Rect.fromLTWH(0, 0, displayWidth * magnifierScale, displayHeight * magnifierScale),
      regionRect: entry.fullImageRegion,
      sampleSize: _maxSampleSize,
      quality: _qualityForScaleAndSize(
        magnifierScale: magnifierScale,
        sampleSize: _maxSampleSize,
        devicePixelRatio: devicePixelRatio,
      ),
    );
    final tiles = [fullImageRegionTile];

    final minSampleSize = min(ExtraAvesEntryImages.sampleSizeForScale(magnifierScale: magnifierScale, devicePixelRatio: devicePixelRatio), _maxSampleSize);
    int nextSampleSize(int sampleSize) => (sampleSize / 2).floor();
    for (var sampleSize = nextSampleSize(_maxSampleSize); sampleSize >= minSampleSize; sampleSize = nextSampleSize(sampleSize)) {
      final regionSide = (_tileSide * sampleSize).round();
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
            tiles.add(_RegionTile(
              entry: entry,
              tileRect: tileRect,
              regionRect: regionRect,
              sampleSize: sampleSize,
              quality: _qualityForScaleAndSize(
                magnifierScale: magnifierScale,
                sampleSize: sampleSize,
                devicePixelRatio: devicePixelRatio,
              ),
            ));
          }
        }
      }
    }
    return tiles;
  }

  Rect _getViewRect(int displayWidth, int displayHeight) {
    final scale = viewState.scale!;
    final centerOffset = viewState.position;
    final viewportSize = viewState.viewportSize!;
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
    if (_tileTransform != null) {
      // apply EXIF orientation
      final regionRectDouble = Rect.fromLTWH(x.toDouble(), y.toDouble(), thisRegionWidth.toDouble(), thisRegionHeight.toDouble());
      final tl = MatrixUtils.transformPoint(_tileTransform!, regionRectDouble.topLeft);
      final br = MatrixUtils.transformPoint(_tileTransform!, regionRectDouble.bottomRight);
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
    if (_displaySize.longestSide < _pixelArtMaxSize) {
      return FilterQuality.none;
    }

    return _qualityForScale(
      magnifierScale: magnifierScale,
      sampleSize: sampleSize,
      devicePixelRatio: devicePixelRatio,
    );
  }
}

class _RegionTile extends StatefulWidget {
  final AvesEntry entry;

  // `tileRect` uses Flutter view coordinates
  // `regionRect` uses the raw image pixel coordinates
  final Rect tileRect;
  final Rectangle<num> regionRect;
  final int sampleSize;
  final FilterQuality quality;

  const _RegionTile({
    required this.entry,
    required this.tileRect,
    required this.regionRect,
    required this.sampleSize,
    required this.quality,
  });

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
        ..translate(w, h)
        ..scale(-1.0, 1.0, 1.0)
        ..translate(-w, -h);
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
