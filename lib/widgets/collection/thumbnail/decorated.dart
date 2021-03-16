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
  final ValueNotifier<bool> cancellableNotifier;
  final bool selectable, highlightable;

  static final Color borderColor = Colors.grey.shade700;
  static const double borderWidth = .5;

  const DecoratedThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.collection,
    this.cancellableNotifier,
    this.selectable = true,
    this.highlightable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // hero tag should include a collection identifier, so that it animates
    // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
    // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
    final heroTag = hashValues(collection?.id, entry);
    final isSvg = entry.isSvg;
    var child = isSvg
        ? VectorImageThumbnail(
            entry: entry,
            extent: extent,
            heroTag: heroTag,
          )
        : RasterImageThumbnail(
            entry: entry,
            extent: extent,
            cancellableNotifier: cancellableNotifier,
            heroTag: heroTag,
          );

    child = Stack(
      alignment: isSvg ? Alignment.center : AlignmentDirectional.bottomStart,
      children: [
        child,
        if (!isSvg)
          ThumbnailEntryOverlay(
            entry: entry,
            extent: extent,
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
