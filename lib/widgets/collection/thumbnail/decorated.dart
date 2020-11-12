import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/thumbnail/overlay.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/collection/thumbnail/vector.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final CollectionLens collection;
  final ValueNotifier<bool> isScrollingNotifier;
  final bool showOverlay;
  final Object heroTag;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  DecoratedThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.collection,
    this.isScrollingNotifier,
    this.showOverlay = true,
  })  : heroTag = collection?.heroTag(entry),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var child = entry.isSvg
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
          );
    if (showOverlay) {
      child = Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            child: ThumbnailEntryOverlay(
              entry: entry,
              extent: extent,
            ),
          ),
          ThumbnailSelectionOverlay(
            entry: entry,
            extent: extent,
          ),
          ThumbnailHighlightOverlay(
            highlightedStream: collection.highlightStream.map((highlighted) => highlighted == entry),
            extent: extent,
          ),
        ],
      );
    }
    return Container(
      foregroundDecoration: BoxDecoration(
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
