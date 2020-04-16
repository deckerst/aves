import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_picture_provider.dart';
import 'package:aves/widgets/common/transition_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DecoratedThumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  const DecoratedThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      width: extent,
      height: extent,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          entry.isSvg
              ? _buildVectorImage()
              : ThumbnailRasterImage(
                  entry: entry,
                  extent: extent,
                  heroTag: heroTag,
                ),
          _ThumbnailOverlay(
            entry: entry,
            extent: extent,
          ),
        ],
      ),
    );
  }

  Widget _buildVectorImage() {
    final child = Container(
      // center `SvgPicture` inside `Container` with the thumbnail dimensions
      // so that `SvgPicture` doesn't get aligned by the `Stack` like the overlay icons
      width: extent,
      height: extent,
      child: SvgPicture(
        UriPicture(
          uri: entry.uri,
          mimeType: entry.mimeType,
          colorFilter: Constants.svgColorFilter,
        ),
        width: extent,
        height: extent,
      ),
    );
    return heroTag == null
        ? child
        : Hero(
            tag: heroTag,
            child: child,
          );
  }
}

class ThumbnailRasterImage extends StatefulWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;

  const ThumbnailRasterImage({
    Key key,
    @required this.entry,
    @required this.extent,
    this.heroTag,
  }) : super(key: key);

  @override
  _ThumbnailRasterImageState createState() => _ThumbnailRasterImageState();
}

class _ThumbnailRasterImageState extends State<ThumbnailRasterImage> {
  ThumbnailProvider _imageProvider;

  ImageEntry get entry => widget.entry;

  double get extent => widget.extent;

  Object get heroTag => widget.heroTag;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  @override
  void didUpdateWidget(ThumbnailRasterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != entry) {
      _cancelProvider();
      _initProvider();
    }
  }

  @override
  void dispose() {
    _cancelProvider();
    super.dispose();
  }

  void _initProvider() => _imageProvider = ThumbnailProvider(entry: entry, extent: Constants.thumbnailCacheExtent);

  void _cancelProvider() => _imageProvider?.cancel();

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: _imageProvider,
      width: extent,
      height: extent,
      fit: BoxFit.cover,
    );
    return heroTag == null
        ? image
        : Hero(
            tag: heroTag,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              ImageProvider heroImageProvider = _imageProvider;
              if (!entry.isVideo && !entry.isSvg) {
                final imageProvider = UriImage(
                  uri: entry.uri,
                  mimeType: entry.mimeType,
                );
                if (imageCache.statusForKey(imageProvider).keepAlive) {
                  heroImageProvider = imageProvider;
                }
              }
              return TransitionImage(
                image: heroImageProvider,
                animation: animation,
              );
            },
            child: image,
          );
  }
}

class _ThumbnailOverlay extends StatelessWidget {
  final ImageEntry entry;
  final double extent;

  const _ThumbnailOverlay({
    Key key,
    @required this.entry,
    @required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = min(14.0, (extent / 8));
    final iconSize = fontSize * 2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.hasGps) GpsIcon(iconSize: iconSize),
        if (entry.isAnimated)
          AnimatedImageIcon(iconSize: iconSize)
        else if (entry.isVideo)
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: fontSize,
            ),
            child: VideoIcon(
              entry: entry,
              iconSize: iconSize,
            ),
          ),
      ],
    );
  }
}
