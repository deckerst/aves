import 'dart:math';
import 'dart:ui';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/settings/enums/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class VectorImageView extends StatefulWidget {
  final AvesEntry entry;
  final ValueNotifier<ViewState> viewStateNotifier;
  final ImageErrorWidgetBuilder errorBuilder;

  const VectorImageView({
    super.key,
    required this.entry,
    required this.viewStateNotifier,
    required this.errorBuilder,
  });

  @override
  State<VectorImageView> createState() => _VectorImageViewState();
}

class _VectorImageViewState extends State<VectorImageView> {
  late Size _displaySize;
  bool _isTilingInitialized = false;
  late double _minScale;
  late double _tileSide;
  ImageStream? _fullImageStream;
  late ImageStreamListener _fullImageListener;
  final ValueNotifier<bool> _fullImageLoaded = ValueNotifier(false);

  AvesEntry get entry => widget.entry;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  ViewState get viewState => viewStateNotifier.value;

  ImageProvider get thumbnailProvider => entry.bestCachedThumbnail;

  Rectangle<double> get fullImageRegion => Rectangle<double>(.0, .0, entry.width.toDouble(), entry.height.toDouble());

  ImageProvider get fullImageProvider {
    assert(_isTilingInitialized);
    return entry.getRegion(
      scale: _minScale,
      region: fullImageRegion,
    );
  }

  @override
  void initState() {
    super.initState();
    _displaySize = entry.displaySize;
    _fullImageListener = ImageStreamListener(_onFullImageCompleted);
  }

  @override
  void didUpdateWidget(covariant VectorImageView oldWidget) {
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
    _fullImageStream!.addListener(_fullImageListener);
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
    if (_displaySize == Size.zero) return widget.errorBuilder(context, 'Not sized', null);

    return ValueListenableBuilder<ViewState>(
      valueListenable: viewStateNotifier,
      builder: (context, viewState, child) {
        final viewportSize = viewState.viewportSize;
        final viewportSized = viewportSize?.isEmpty == false;
        if (viewportSized && !_isTilingInitialized) _initTiling(viewportSize!);

        return SizedBox.fromSize(
          size: _displaySize * viewState.scale!,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildLoading(),
              ..._getTiles(),
            ],
          ),
        );
      },
    );
  }

  void _initTiling(Size viewportSize) {
    _tileSide = _displaySize.longestSide;
    // scale for initial state `contained`
    final containedScale = min(viewportSize.width / _displaySize.width, viewportSize.height / _displaySize.height);
    _minScale = _imageScaleForViewScale(containedScale);

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

  List<Widget> _getTiles() {
    if (!_isTilingInitialized) return [];

    final displayWidth = _displaySize.width;
    final displayHeight = _displaySize.height;
    final viewRect = _getViewRect(displayWidth, displayHeight);
    final viewScale = viewState.scale!;
    final background = settings.imageBackground;

    Color? backgroundColor;
    _BackgroundFrameBuilder? backgroundFrameBuilder;
    if (background.isColor) {
      backgroundColor = background.color;
    } else if (background == EntryBackground.checkered) {
      final viewportSize = viewState.viewportSize!;
      final viewSize = _displaySize * viewState.scale!;

      final backgroundSize = applyBoxFit(BoxFit.none, viewSize, viewportSize).source;
      var backgroundOffset = ((viewSize - viewportSize) as Offset) / 2 - viewState.position;
      backgroundOffset = Offset(max(0, backgroundOffset.dx), max(0, backgroundOffset.dy));
      backgroundOffset += ((backgroundSize - viewportSize) as Offset) / 2;

      final side = viewportSize.shortestSide;
      final checkSize = side / ((side / EntryPageView.decorationCheckSize).round());

      backgroundFrameBuilder = (child, frame, tileRect) {
        return frame == null
            ? const SizedBox()
            : DecoratedBox(
                decoration: _CheckeredBackgroundDecoration(
                  viewportSize: viewportSize,
                  checkSize: checkSize,
                  offset: backgroundOffset - tileRect.topLeft,
                ),
                child: child,
              );
      };
    }

    // for the largest sample size (matching the initial scale), the whole image is in view
    // so we subsample the whole image without tiling
    final fullImageRegionTile = _RegionTile(
      entry: entry,
      tileRect: Rect.fromLTWH(0, 0, displayWidth * viewScale, displayHeight * viewScale),
      regionRect: fullImageRegion,
      scale: _minScale,
      backgroundColor: backgroundColor,
      backgroundFrameBuilder: backgroundFrameBuilder,
    );
    final tiles = <Widget>[fullImageRegionTile];

    final maxSvgScale = max(_imageScaleForViewScale(viewScale), _minScale);
    double nextScale(double scale) => scale * 2;
    // add `alpha` to the region side so that tiles do not align across layers,
    // which helps the checkered background deflation workaround
    // for the tile background bleeding issue
    var alpha = 0;
    for (var svgScale = nextScale(_minScale); svgScale <= maxSvgScale; svgScale = nextScale(svgScale)) {
      final regionSide = (_tileSide + alpha++) / (svgScale / _minScale);
      for (var x = .0; x < displayWidth; x += regionSide) {
        for (var y = .0; y < displayHeight; y += regionSide) {
          final rects = _getTileRects(
            x: x,
            y: y,
            regionSide: regionSide,
            displayWidth: displayWidth,
            displayHeight: displayHeight,
            scale: viewScale,
            viewRect: viewRect,
          );
          if (rects != null) {
            tiles.add(_RegionTile(
              entry: entry,
              tileRect: rects.item1,
              regionRect: rects.item2,
              scale: svgScale,
              backgroundColor: backgroundColor,
              backgroundFrameBuilder: backgroundFrameBuilder,
            ));
          }
        }
      }
    }
    return tiles;
  }

  Rect _getViewRect(double displayWidth, double displayHeight) {
    final scale = viewState.scale!;
    final centerOffset = viewState.position;
    final viewportSize = viewState.viewportSize!;
    final viewOrigin = Offset(
      ((displayWidth * scale - viewportSize.width) / 2 - centerOffset.dx),
      ((displayHeight * scale - viewportSize.height) / 2 - centerOffset.dy),
    );
    return viewOrigin & viewportSize;
  }

  Tuple2<Rect, Rectangle<double>>? _getTileRects({
    required double x,
    required double y,
    required double regionSide,
    required double displayWidth,
    required double displayHeight,
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

    final regionRect = Rectangle<double>(x, y, thisRegionWidth, thisRegionHeight);
    return Tuple2<Rect, Rectangle<double>>(tileRect, regionRect);
  }

  double _imageScaleForViewScale(double scale) => smallestPowerOf2(scale * window.devicePixelRatio).toDouble();
}

typedef _BackgroundFrameBuilder = Widget Function(Widget child, int? frame, Rect tileRect);

class _RegionTile extends StatefulWidget {
  final AvesEntry entry;

  // `tileRect` uses Flutter view coordinates
  // `regionRect` uses the raw image pixel coordinates
  final Rect tileRect;
  final Rectangle<double> regionRect;
  final double scale;
  final Color? backgroundColor;
  final _BackgroundFrameBuilder? backgroundFrameBuilder;

  const _RegionTile({
    required this.entry,
    required this.tileRect,
    required this.regionRect,
    required this.scale,
    required this.backgroundColor,
    required this.backgroundFrameBuilder,
  });

  @override
  State<_RegionTile> createState() => _RegionTileState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('id', entry.id));
    properties.add(IntProperty('contentId', entry.contentId));
    properties.add(DiagnosticsProperty<Rect>('tileRect', tileRect));
    properties.add(DiagnosticsProperty<Rectangle<double>>('regionRect', regionRect));
    properties.add(DoubleProperty('scale', scale));
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
    if (oldWidget.entry != widget.entry || oldWidget.tileRect != widget.tileRect || oldWidget.scale != widget.scale || oldWidget.scale != widget.scale) {
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
      scale: widget.scale,
      region: widget.regionRect,
    );
  }

  void _pauseProvider() => _provider.pause();

  @override
  Widget build(BuildContext context) {
    final tileRect = widget.tileRect;

    Widget child = Image(
      image: _provider,
      frameBuilder: (_, child, frame, __) => widget.backgroundFrameBuilder?.call(child, frame, tileRect) ?? child,
      width: tileRect.width,
      height: tileRect.height,
      color: widget.backgroundColor,
      colorBlendMode: BlendMode.dstOver,
      fit: BoxFit.fill,
    );

    return Positioned.fromRect(
      rect: tileRect,
      child: child,
    );
  }
}

class _CheckeredBackgroundDecoration extends Decoration {
  final Size viewportSize;
  final double checkSize;
  final Offset offset;

  const _CheckeredBackgroundDecoration({
    required this.viewportSize,
    required this.checkSize,
    required this.offset,
  });

  @override
  _CheckeredBackgroundDecorationPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CheckeredBackgroundDecorationPainter(this, onChanged);
  }
}

class _CheckeredBackgroundDecorationPainter extends BoxPainter {
  final _CheckeredBackgroundDecoration decoration;

  const _CheckeredBackgroundDecorationPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  static const deflation = Offset(.5, .5);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    var decorated = offset & size;
    // deflate background as a workaround for background bleeding beyond tile image
    decorated = Rect.fromLTRB(
      decorated.left + deflation.dx,
      decorated.top + deflation.dy,
      decorated.right - deflation.dx,
      decorated.bottom - deflation.dy,
    );

    final visible = decorated.intersect(Offset.zero & decoration.viewportSize);
    final checkOffset = decoration.offset + decorated.topLeft - visible.topLeft - deflation;

    final translation = Offset(max(0, offset.dx + deflation.dx), max(0, offset.dy + deflation.dy));
    canvas.translate(translation.dx, translation.dy);
    CheckeredPainter(
      checkSize: decoration.checkSize,
      offset: checkOffset,
    ).paint(canvas, visible.size);
    canvas.translate(-translation.dx, -translation.dy);
  }
}
