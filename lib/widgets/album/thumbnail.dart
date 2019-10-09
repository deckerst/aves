import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_preview.dart';
import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final double devicePixelRatio;

  const Thumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = ImagePreview(
      entry: entry,
      width: extent,
      height: extent,
      devicePixelRatio: devicePixelRatio,
      builder: (bytes) {
        return Hero(
          tag: entry.uri,
          child: LayoutBuilder(builder: (context, constraints) {
            final dim = min(constraints.maxWidth, constraints.maxHeight);
            return Image.memory(
              bytes,
              width: dim,
              height: dim,
              fit: BoxFit.cover,
            );
          }),
        );
      },
    );
    final icons = _buildOverlayIcons();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: icons != null
          ? Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                image,
                icons,
              ],
            )
          : image,
    );
  }

  Widget _buildOverlayIcons() {
    final fontSize = min(14.0, (extent / 8).roundToDouble());
    final iconSize = fontSize * 2;
    final icons = [
      if (entry.hasGps) GpsIcon(iconSize: iconSize),
      if (entry.isGif)
        GifIcon(iconSize: iconSize)
      else if (entry.isVideo)
        VideoIcon(
          entry: entry,
          iconSize: iconSize,
        ),
    ];
    return icons.isNotEmpty
        ? DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: fontSize,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: icons,
            ),
          )
        : null;
  }
}
