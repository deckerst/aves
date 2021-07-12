import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/thumbnail/image.dart';
import 'package:aves/widgets/collection/thumbnail/overlay.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/grid/overlay.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final AvesEntry entry;
  final double tileExtent;
  final CollectionLens? collection;
  final ValueNotifier<bool>? cancellableNotifier;
  final bool selectable, highlightable;

  static final Color borderColor = Colors.grey.shade700;
  static final double borderWidth = AvesBorder.borderWidth;

  const DecoratedThumbnail({
    Key? key,
    required this.entry,
    required this.tileExtent,
    this.collection,
    this.cancellableNotifier,
    this.selectable = true,
    this.highlightable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageExtent = tileExtent - borderWidth * 2;

    // hero tag should include a collection identifier, so that it animates
    // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
    // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
    final heroTag = hashValues(collection?.id, entry);
    final isSvg = entry.isSvg;
    Widget child = ThumbnailImage(
      entry: entry,
      extent: imageExtent,
      cancellableNotifier: cancellableNotifier,
      heroTag: heroTag,
    );

    child = Stack(
      alignment: isSvg ? Alignment.center : AlignmentDirectional.bottomStart,
      children: [
        child,
        if (!isSvg) ThumbnailEntryOverlay(entry: entry),
        if (selectable) GridItemSelectionOverlay(item: entry),
        if (highlightable) ThumbnailHighlightOverlay(entry: entry),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
          color: borderColor,
          width: borderWidth,
        )),
      ),
      width: tileExtent,
      height: tileExtent,
      child: child,
    );
  }
}
