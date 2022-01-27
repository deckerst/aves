import 'package:aves/model/entry.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/grid/overlay.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/common/thumbnail/overlay.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final AvesEntry entry;
  final double tileExtent;
  final ValueNotifier<bool>? cancellableNotifier;
  final bool selectable, highlightable;
  final Object? Function()? heroTagger;

  static final Color borderColor = Colors.grey.shade700;
  static final double borderWidth = AvesBorder.straightBorderWidth;

  const DecoratedThumbnail({
    Key? key,
    required this.entry,
    required this.tileExtent,
    this.cancellableNotifier,
    this.selectable = true,
    this.highlightable = true,
    this.heroTagger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSvg = entry.isSvg;
    Widget child = ThumbnailImage(
      entry: entry,
      extent: tileExtent,
      cancellableNotifier: cancellableNotifier,
      heroTag: heroTagger?.call(),
    );

    child = Stack(
      alignment: isSvg ? Alignment.center : AlignmentDirectional.bottomStart,
      children: [
        child,
        if (!isSvg) ThumbnailEntryOverlay(entry: entry),
        if (selectable)
          GridItemSelectionOverlay<AvesEntry>(
            item: entry,
            padding: const EdgeInsets.all(2),
          ),
        if (highlightable) ThumbnailHighlightOverlay(entry: entry),
      ],
    );

    return Container(
      // `decoration` with sub logical pixel width yields scintillating borders
      // so we use `foregroundDecoration` instead
      foregroundDecoration: BoxDecoration(
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
