import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/thumbnail/overlay.dart';
import 'package:aves/widgets/album/thumbnail/raster.dart';
import 'package:aves/widgets/album/thumbnail/vector.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;
  final ValueNotifier<bool> isScrollingNotifier;
  final bool showOverlay;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  const DecoratedThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.heroTag,
    this.isScrollingNotifier,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        entry.isSvg
            ? ThumbnailVectorImage(
                entry: entry,
                extent: extent,
                heroTag: heroTag,
              )
            : ThumbnailRasterImage(
                entry: entry,
                extent: extent,
                isScrollingNotifier: isScrollingNotifier,
                heroTag: heroTag,
              ),
        if (showOverlay)
          Positioned(
            bottom: 0,
            left: 0,
            child: ThumbnailEntryOverlay(
              entry: entry,
              extent: extent,
            ),
          ),
        if (showOverlay)
          ThumbnailSelectionOverlay(
            entry: entry,
            extent: extent,
          ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      width: extent,
      height: extent,
      child: child,
    );
  }
}
