import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_preview.dart';
import 'package:aves/widgets/fullscreen/uri_picture_provider.dart';
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
    return ImagePreview(
      entry: entry,
      // TODO TLAD smarter sizing, but shouldn't only depend on `extent` so that it doesn't reload during gridview scaling
      width: 50,
      height: 50,
      builder: (bytes) {
        final imageBuilder = (bytes, dim) => Image.memory(
              bytes,
              width: dim,
              height: dim,
              fit: BoxFit.cover,
            );
        return heroTag == null
            ? imageBuilder(bytes, extent)
            : Hero(
                tag: heroTag,
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                  // use LayoutBuilder only during hero animation
                  return LayoutBuilder(builder: (context, constraints) {
                    final dim = min(constraints.maxWidth, constraints.maxHeight);
                    return imageBuilder(bytes, dim);
                  });
                },
                child: imageBuilder(bytes, extent),
              );
      },
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
