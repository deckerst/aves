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

class Thumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  const Thumbnail({
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
          entry.isSvg ? _buildVectorImage() : _buildRasterImage(),
          _ThumbnailOverlay(
            entry: entry,
            extent: extent,
          ),
        ],
      ),
    );
  }

  Widget _buildRasterImage() {
    final thumbnailProvider = ThumbnailProvider(entry: entry, extent: Constants.thumbnailCacheExtent);
    final image = Image(
      image: thumbnailProvider,
      width: extent,
      height: extent,
      fit: BoxFit.cover,
    );
    return heroTag == null
        ? image
        : Hero(
            tag: heroTag,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              ImageProvider heroImageProvider = thumbnailProvider;
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
        if (entry.isGif)
          GifIcon(iconSize: iconSize)
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
