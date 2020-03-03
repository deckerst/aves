import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_preview.dart';
import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;

  const Thumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = ImagePreview(
      entry: entry,
      // TODO TLAD smarter sizing, but shouldn't only depend on `extent` so that it doesn't reload during gridview scaling
      width: 50,
      height: 50,
      builder: (bytes) {
        return Hero(
          tag: entry.uri,
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            // use LayoutBuilder only during hero animation
            return LayoutBuilder(builder: (context, constraints) {
              final dim = min(constraints.maxWidth, constraints.maxHeight);
              return Image.memory(
                bytes,
                width: dim,
                height: dim,
                fit: BoxFit.cover,
              );
            });
          },
          child: Image.memory(
            bytes,
            width: extent,
            height: extent,
            fit: BoxFit.cover,
          ),
        );
      },
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          image,
          _ThumbnailOverlay(
            entry: entry,
            extent: extent,
          ),
        ],
      ),
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
    final fontSize = min(14.0, (extent / 8).roundToDouble());
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
