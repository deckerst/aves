import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/image_providers/region_provider.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TiledImageView extends StatefulWidget {
  final ImageEntry entry;
  final Size viewportSize;
  final ValueNotifier<ViewState> viewStateNotifier;
  final Widget baseChild;
  final ImageErrorWidgetBuilder errorBuilder;

  const TiledImageView({
    @required this.entry,
    @required this.viewportSize,
    @required this.viewStateNotifier,
    @required this.baseChild,
    @required this.errorBuilder,
  });

  @override
  _TiledImageViewState createState() => _TiledImageViewState();
}

class _TiledImageViewState extends State<TiledImageView> {
  double _tileSide, _initialScale;
  int _maxSampleSize;
  Matrix4 _transform;

  ImageEntry get entry => widget.entry;

  Size get viewportSize => widget.viewportSize;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  // magic number used to derive sample size from scale
  static const scaleFactor = 2.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(TiledImageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.viewportSize != widget.viewportSize || oldWidget.entry.displaySize != widget.entry.displaySize) {
      _init();
    }
  }

  void _init() {
    _tileSide = viewportSize.shortestSide * scaleFactor;
    _initialScale = min(viewportSize.width / entry.displaySize.width, viewportSize.height / entry.displaySize.height);
    _maxSampleSize = _sampleSizeForScale(_initialScale);

    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;
    _transform = null;
    if (rotationDegrees != 0 || isFlipped) {
      _transform = Matrix4.identity()
        ..translate(entry.width / 2.0, entry.height / 2.0)
        ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
        ..rotateZ(-toRadians(rotationDegrees.toDouble()))
        ..translate(-entry.displaySize.width / 2.0, -entry.displaySize.height / 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (viewStateNotifier == null) return SizedBox.shrink();

    final displayWidth = entry.displaySize.width.round();
    final displayHeight = entry.displaySize.height.round();

    return AnimatedBuilder(
        animation: viewStateNotifier,
        builder: (context, child) {
          final viewState = viewStateNotifier.value;
          var scale = viewState.scale;
          if (scale == 0.0) {
            // for initial scale as `PhotoViewComputedScale.contained`
            scale = _initialScale;
          }

          final centerOffset = viewState.position;
          final viewOrigin = Offset(
            ((displayWidth * scale - viewportSize.width) / 2 - centerOffset.dx),
            ((displayHeight * scale - viewportSize.height) / 2 - centerOffset.dy),
          );
          final viewRect = viewOrigin & viewportSize;

          final tiles = <RegionTile>[];
          var minSampleSize = min(_sampleSizeForScale(scale), _maxSampleSize);
          for (var sampleSize = _maxSampleSize; sampleSize >= minSampleSize; sampleSize = (sampleSize / 2).floor()) {
            // for the largest sample size (matching the initial scale), the whole image is in view
            // so we subsample the whole image instead of splitting it in tiles
            final useTiles = sampleSize != _maxSampleSize;
            final regionSide = (_tileSide * sampleSize).round();
            final layerRegionWidth = useTiles ? regionSide : displayWidth;
            final layerRegionHeight = useTiles ? regionSide : displayHeight;
            for (var x = 0; x < displayWidth; x += layerRegionWidth) {
              for (var y = 0; y < displayHeight; y += layerRegionHeight) {
                final nextX = x + layerRegionWidth;
                final nextY = y + layerRegionHeight;
                final thisRegionWidth = layerRegionWidth - (nextX >= displayWidth ? nextX - displayWidth : 0);
                final thisRegionHeight = layerRegionHeight - (nextY >= displayHeight ? nextY - displayHeight : 0);
                final tileRect = Rect.fromLTWH(x * scale, y * scale, thisRegionWidth * scale, thisRegionHeight * scale);

                // only build visible tiles
                if (viewRect.overlaps(tileRect)) {
                  Rectangle<int> regionRect;

                  if (_transform != null) {
                    // apply EXIF orientation
                    final regionRectDouble = Rect.fromLTWH(x.toDouble(), y.toDouble(), thisRegionWidth.toDouble(), thisRegionHeight.toDouble());
                    final tl = MatrixUtils.transformPoint(_transform, regionRectDouble.topLeft);
                    final br = MatrixUtils.transformPoint(_transform, regionRectDouble.bottomRight);
                    regionRect = Rectangle<int>.fromPoints(
                      Point<int>(tl.dx.round(), tl.dy.round()),
                      Point<int>(br.dx.round(), br.dy.round()),
                    );
                  } else {
                    regionRect = Rectangle<int>(x, y, thisRegionWidth, thisRegionHeight);
                  }

                  tiles.add(RegionTile(
                    entry: entry,
                    tileRect: tileRect,
                    regionRect: regionRect,
                    sampleSize: sampleSize,
                  ));
                }
              }
            }
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: displayWidth * scale,
                height: displayHeight * scale,
                child: widget.baseChild,
              ),
              ...tiles,
            ],
          );
        });
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
