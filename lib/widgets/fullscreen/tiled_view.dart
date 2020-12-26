import 'dart:math';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class TiledImageView extends StatefulWidget {
  final ImageEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final ImageErrorWidgetBuilder errorBuilder;

  const TiledImageView({
    @required this.entry,
    @required this.viewStateNotifier,
    @required this.errorBuilder,
  });

  @override
  _TiledImageViewState createState() => _TiledImageViewState();
}

class _TiledImageViewState extends State<TiledImageView> {
  bool _isTilingInitialized = false;
  int _maxSampleSize;
  double _tileSide;
  Matrix4 _tileTransform;
  ImageStream _fullImageStream;
  ImageStreamListener _fullImageListener;
  final ValueNotifier<bool> _fullImageLoaded = ValueNotifier(false);

  ImageEntry get entry => widget.entry;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  bool get useBackground => entry.canHaveAlpha && settings.rasterBackground != EntryBackground.transparent;

  bool get useTiles => entry.canTile && (entry.width > 4096 || entry.height > 4096);

  ImageProvider get thumbnailProvider => ThumbnailProvider(ThumbnailProviderKey.fromEntry(entry));

  ImageProvider get fullImageProvider {
    if (useTiles) {
      assert(_isTilingInitialized);
      final displayWidth = entry.displaySize.width.round();
      final displayHeight = entry.displaySize.height.round();
      final viewState = viewStateNotifier.value;
      final regionRect = _getTileRects(
        x: 0,
        y: 0,
        layerRegionWidth: displayWidth,
        layerRegionHeight: displayHeight,
        displayWidth: displayWidth,
        displayHeight: displayHeight,
        scale: viewState.scale,
        viewRect: _getViewRect(viewState, displayWidth, displayHeight),
      ).item2;
      return RegionProvider(RegionProviderKey.fromEntry(
        entry,
        sampleSize: _maxSampleSize,
        rect: regionRect,
      ));
    } else {
      return UriImage(
        uri: entry.uri,
        mimeType: entry.mimeType,
        rotationDegrees: entry.rotationDegrees,
        isFlipped: entry.isFlipped,
        expectedContentLength: entry.sizeBytes,
      );
    }
  }

  // magic number used to derive sample size from scale
  static const scaleFactor = 2.0;

  @override
  void initState() {
    super.initState();
    _fullImageListener = ImageStreamListener(_onFullImageCompleted);
    if (!useTiles) _registerFullImage();
  }

  @override
  void didUpdateWidget(TiledImageView oldWidget) {
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
    _unregisterFullImage();
    super.dispose();
  }

  void _registerFullImage() {
    _fullImageStream = fullImageProvider.resolve(ImageConfiguration.empty);
    _fullImageStream.addListener(_fullImageListener);
  }

  void _unregisterFullImage() {
    _fullImageStream?.removeListener(_fullImageListener);
    _fullImageStream = null;
  }

  void _onFullImageCompleted(ImageInfo image, bool synchronousCall) {
    _unregisterFullImage();
    _fullImageLoaded.value = true;
  }

  @override
  Widget build(BuildContext context) {
    if (viewStateNotifier == null) return SizedBox.shrink();

    return ValueListenableBuilder<ViewState>(
      valueListenable: viewStateNotifier,
      builder: (context, viewState, child) {
        final viewportSize = viewState.viewportSize;
        final viewportSized = viewportSize != null;
        if (viewportSized && useTiles && !_isTilingInitialized) _initTiling(viewportSize);

        return SizedBox.fromSize(
          size: entry.displaySize * viewState.scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (useBackground && viewportSized) _buildBackground(viewState),
              _buildLoading(viewState),
              if (useTiles) ..._getTiles(viewState),
              if (!useTiles)
                Image(
                  image: fullImageProvider,
                  gaplessPlayback: true,
                  errorBuilder: widget.errorBuilder,
                  width: (entry.displaySize * viewState.scale).width,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
            ],
          ),
        );
      },
    );
  }

  void _initTiling(Size viewportSize) {
    final displaySize = entry.displaySize;
    _tileSide = viewportSize.shortestSide * scaleFactor;
    // scale for initial state `contained`
    final containedScale = min(viewportSize.width / displaySize.width, viewportSize.height / displaySize.height);
    _maxSampleSize = _sampleSizeForScale(containedScale);

    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;
    _tileTransform = null;
    if (rotationDegrees != 0 || isFlipped) {
      _tileTransform = Matrix4.identity()
        ..translate(entry.width / 2.0, entry.height / 2.0)
        ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
        ..rotateZ(-toRadians(rotationDegrees.toDouble()))
        ..translate(-displaySize.width / 2.0, -displaySize.height / 2.0);
    }
    _isTilingInitialized = true;
    _registerFullImage();
  }

  Widget _buildLoading(ViewState viewState) {
    return ValueListenableBuilder(
      valueListenable: _fullImageLoaded,
      builder: (context, fullImageLoaded, child) {
        if (fullImageLoaded) return SizedBox.shrink();

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

  Widget _buildBackground(ViewState viewState) {
    final viewportSize = viewState.viewportSize;
    assert(viewportSize != null);

    final viewSize = entry.displaySize * viewState.scale;
    final decorationOffset = ((viewSize - viewportSize) as Offset) / 2 - viewState.position;
    final decorationSize = applyBoxFit(BoxFit.none, viewSize, viewportSize).source;

    Decoration decoration;
    final background = settings.rasterBackground;
    if (background == EntryBackground.checkered) {
      final side = viewportSize.shortestSide;
      final checkSize = side / ((side / ImageView.decorationCheckSize).round());
      final offset = ((decorationSize - viewportSize) as Offset) / 2;
      decoration = CheckeredDecoration(
        checkSize: checkSize,
        offset: offset,
      );
    } else {
      decoration = BoxDecoration(
        color: background.color,
      );
    }
    return Positioned(
      left: decorationOffset.dx >= 0 ? decorationOffset.dx : null,
      top: decorationOffset.dy >= 0 ? decorationOffset.dy : null,
      width: decorationSize.width,
      height: decorationSize.height,
      child: DecoratedBox(
        decoration: decoration,
      ),
    );
  }

  List<Widget> _getTiles(ViewState viewState) {
    if (!_isTilingInitialized) return [];

    final displayWidth = entry.displaySize.width.round();
    final displayHeight = entry.displaySize.height.round();
    final viewRect = _getViewRect(viewState, displayWidth, displayHeight);
    final scale = viewState.scale;

    final tiles = <RegionTile>[];
    var minSampleSize = min(_sampleSizeForScale(scale), _maxSampleSize);
    for (var sampleSize = _maxSampleSize; sampleSize >= minSampleSize; sampleSize = (sampleSize / 2).floor()) {
      // for the largest sample size (matching the initial scale), the whole image is in view
      // so we subsample the whole image without tiling
      final fullImageRegion = sampleSize == _maxSampleSize;
      final regionSide = (_tileSide * sampleSize).round();
      final layerRegionWidth = fullImageRegion ? displayWidth : regionSide;
      final layerRegionHeight = fullImageRegion ? displayHeight : regionSide;
      for (var x = 0; x < displayWidth; x += layerRegionWidth) {
        for (var y = 0; y < displayHeight; y += layerRegionHeight) {
          final rects = _getTileRects(
            x: x,
            y: y,
            layerRegionWidth: layerRegionWidth,
            layerRegionHeight: layerRegionHeight,
            displayWidth: displayWidth,
            displayHeight: displayHeight,
            scale: scale,
            viewRect: viewRect,
          );
          if (rects != null) {
            tiles.add(RegionTile(
              entry: entry,
              tileRect: rects.item1,
              regionRect: rects.item2,
              sampleSize: sampleSize,
            ));
          }
        }
      }
    }
    return tiles;
  }

  Rect _getViewRect(ViewState viewState, int displayWidth, int displayHeight) {
    final scale = viewState.scale;
    final centerOffset = viewState.position;
    final viewportSize = viewState.viewportSize;
    final viewOrigin = Offset(
      ((displayWidth * scale - viewportSize.width) / 2 - centerOffset.dx),
      ((displayHeight * scale - viewportSize.height) / 2 - centerOffset.dy),
    );
    return viewOrigin & viewportSize;
  }

  Tuple2<Rect, Rectangle<int>> _getTileRects({
    @required int x,
    @required int y,
    @required int layerRegionWidth,
    @required int layerRegionHeight,
    @required int displayWidth,
    @required int displayHeight,
    @required double scale,
    @required Rect viewRect,
  }) {
    final nextX = x + layerRegionWidth;
    final nextY = y + layerRegionHeight;
    final thisRegionWidth = layerRegionWidth - (nextX >= displayWidth ? nextX - displayWidth : 0);
    final thisRegionHeight = layerRegionHeight - (nextY >= displayHeight ? nextY - displayHeight : 0);
    final tileRect = Rect.fromLTWH(x * scale, y * scale, thisRegionWidth * scale, thisRegionHeight * scale);

    // only build visible tiles
    if (!viewRect.overlaps(tileRect)) return null;

    Rectangle<int> regionRect;
    if (_tileTransform != null) {
      // apply EXIF orientation
      final regionRectDouble = Rect.fromLTWH(x.toDouble(), y.toDouble(), thisRegionWidth.toDouble(), thisRegionHeight.toDouble());
      final tl = MatrixUtils.transformPoint(_tileTransform, regionRectDouble.topLeft);
      final br = MatrixUtils.transformPoint(_tileTransform, regionRectDouble.bottomRight);
      regionRect = Rectangle<int>.fromPoints(
        Point<int>(tl.dx.round(), tl.dy.round()),
        Point<int>(br.dx.round(), br.dy.round()),
      );
    } else {
      regionRect = Rectangle<int>(x, y, thisRegionWidth, thisRegionHeight);
    }
    return Tuple2<Rect, Rectangle<int>>(tileRect, regionRect);
  }

  int _sampleSizeForScale(double scale) {
    var sample = 0;
    if (0 < scale && scale < 1) {
      sample = highestPowerOf2((1 / scale) / scaleFactor);
    }
    return max<int>(1, sample);
  }
}

class RegionTile extends StatefulWidget {
  final ImageEntry entry;

  // `tileRect` uses Flutter view coordinates
  // `regionRect` uses the raw image pixel coordinates
  final Rect tileRect;
  final Rectangle<int> regionRect;
  final int sampleSize;

  const RegionTile({
    @required this.entry,
    @required this.tileRect,
    @required this.regionRect,
    @required this.sampleSize,
  });

  @override
  _RegionTileState createState() => _RegionTileState();
}

class _RegionTileState extends State<RegionTile> {
  RegionProvider _provider;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(RegionTile oldWidget) {
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

  void _registerWidget(RegionTile widget) {
    _initProvider();
  }

  void _unregisterWidget(RegionTile widget) {
    _pauseProvider();
  }

  void _initProvider() {
    if (!entry.canDecode) return;

    _provider = RegionProvider(RegionProviderKey.fromEntry(
      entry,
      sampleSize: widget.sampleSize,
      rect: widget.regionRect,
    ));
  }

  void _pauseProvider() => _provider?.pause();

  @override
  Widget build(BuildContext context) {
    final tileRect = widget.tileRect;

    Widget child = Image(
      image: _provider,
      width: tileRect.width,
      height: tileRect.height,
      fit: BoxFit.fill,
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

    return Positioned.fromRect(
      rect: tileRect,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('contentId', widget.entry.contentId));
    properties.add(IntProperty('sampleSize', widget.sampleSize));
    properties.add(DiagnosticsProperty<Rectangle<int>>('regionRect', widget.regionRect));
  }
}
