import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/image_providers/uri_region_provider.dart';
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
  double _initialScale;
  int _maxSampleSize;

  ImageEntry get entry => widget.entry;

  Size get viewportSize => widget.viewportSize;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  static const tileSide = 200.0;

  // margin around visible area to fetch surrounding tiles in advance
  static const preFetchMargin = 50.0;

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
    _initialScale = min(viewportSize.width / entry.displaySize.width, viewportSize.height / entry.displaySize.height);
    _maxSampleSize = _sampleSizeForScale(_initialScale);
  }

  @override
  Widget build(BuildContext context) {
    if (viewStateNotifier == null) return SizedBox.shrink();

    final displayWidth = entry.displaySize.width;
    final displayHeight = entry.displaySize.height;
    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;
    Matrix4 transform;
    if (rotationDegrees != 0 || isFlipped) {
      transform = Matrix4.identity()
        ..translate(entry.width / 2.0, entry.height / 2.0)
        ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
        ..rotateZ(-toRadians(rotationDegrees.toDouble()))
        ..translate(-displayWidth / 2.0, -displayHeight / 2.0);
    }

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
          final viewRect = (viewOrigin & viewportSize).inflate(preFetchMargin);

          final tiles = <Widget>[];
          var minSampleSize = min(_sampleSizeForScale(scale), _maxSampleSize);
          for (var sampleSize = _maxSampleSize; sampleSize >= minSampleSize; sampleSize = (sampleSize / 2).floor()) {
            final layerRegionSize = Size.square(tileSide * sampleSize);
            for (var x = 0.0; x < displayWidth; x += layerRegionSize.width) {
              for (var y = 0.0; y < displayHeight; y += layerRegionSize.height) {
                final regionOrigin = Offset(x, y);
                final nextOrigin = regionOrigin.translate(layerRegionSize.width, layerRegionSize.height);
                final thisRegionSize = Size(
                  layerRegionSize.width - (nextOrigin.dx >= displayWidth ? nextOrigin.dx - displayWidth : 0),
                  layerRegionSize.height - (nextOrigin.dy >= displayHeight ? nextOrigin.dy - displayHeight : 0),
                );
                final tileRect = regionOrigin * scale & thisRegionSize * scale;

                // only build visible tiles
                if (viewRect.overlaps(tileRect)) {
                  var regionRect = regionOrigin & thisRegionSize;

                  // apply EXIF orientation
                  if (transform != null) {
                    regionRect = Rect.fromPoints(
                      MatrixUtils.transformPoint(transform, regionRect.topLeft),
                      MatrixUtils.transformPoint(transform, regionRect.bottomRight),
                    );
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
      sample = pow(2, (log(1 / scale) / log(2)).floor());
    }
    return max<int>(1, sample);
  }
}

class RegionTile extends StatelessWidget {
  final ImageEntry entry;
  // `tileRect` uses Flutter view coordinates
  // `regionRect` uses the raw image pixel coordinates
  final Rect tileRect, regionRect;
  final int sampleSize;

  const RegionTile({
    @required this.entry,
    @required this.tileRect,
    @required this.regionRect,
    @required this.sampleSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Image(
      image: UriRegion(
        uri: entry.uri,
        mimeType: entry.mimeType,
        rotationDegrees: entry.rotationDegrees,
        isFlipped: entry.isFlipped,
        sampleSize: sampleSize,
        rect: regionRect,
      ),
      width: tileRect.width,
      height: tileRect.height,
      fit: BoxFit.fill,
      // TODO TLAD remove when done with tiling
      // color: Color.fromARGB((0xff / sampleSize).floor(), 0, 0, 0xff),
      // colorBlendMode: BlendMode.color,
    );

    // child = Container(
    //   foregroundDecoration: BoxDecoration(
    //     border: Border.all(
    //       color: Colors.cyan,
    //     ),
    //   ),
    //   // child: Text('$sampleSize'),
    //   child: child,
    // );

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
}
