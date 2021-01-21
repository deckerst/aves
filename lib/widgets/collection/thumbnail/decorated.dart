import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/thumbnail/overlay.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/collection/thumbnail/vector.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final AvesEntry entry;
  final double extent;
  final CollectionLens collection;
  final ValueNotifier<bool> isScrollingNotifier;
  final bool selectable, highlightable;
  final Object heroTag;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  DecoratedThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.collection,
    this.isScrollingNotifier,
    this.selectable = true,
    this.highlightable = true,
  })  : heroTag = collection?.heroTag(entry),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var child = entry.isSvg
        ? VectorImageThumbnail(
            entry: entry,
            extent: extent,
            heroTag: heroTag,
          )
        : RasterImageThumbnail(
            entry: entry,
            extent: extent,
            isScrollingNotifier: isScrollingNotifier,
            heroTag: heroTag,
          );

    child = Stack(
      alignment: Alignment.center,
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
        if (selectable)
          ThumbnailSelectionOverlay(
            entry: entry,
            extent: extent,
          ),
        if (highlightable)
          ThumbnailHighlightOverlay(
            entry: entry,
            extent: extent,
          ),
      ],
    );

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
