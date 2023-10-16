import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/grid/overlay.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/section_layout_builder.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/common/thumbnail/notifications.dart';
import 'package:aves/widgets/common/thumbnail/overlay.dart';
import 'package:flutter/material.dart';

class DecoratedThumbnail extends StatelessWidget {
  final AvesEntry entry;
  final double tileExtent;
  final ValueNotifier<bool>? cancellableNotifier;
  final bool isMosaic, selectable, highlightable;
  final Object? Function()? heroTagger;

  static final Color borderColor = Colors.grey.shade700;

  static double borderWidth(BuildContext context) => AvesBorder.straightBorderWidth(context);

  const DecoratedThumbnail({
    super.key,
    required this.entry,
    required this.tileExtent,
    this.cancellableNotifier,
    this.isMosaic = false,
    this.selectable = true,
    this.highlightable = true,
    this.heroTagger,
  });

  @override
  Widget build(BuildContext context) {
    final double thumbnailHeight = tileExtent;
    final double thumbnailWidth;
    if (isMosaic) {
      thumbnailWidth = thumbnailHeight *
          entry.displayAspectRatio.clamp(
            MosaicSectionLayoutBuilder.minThumbnailAspectRatio,
            MosaicSectionLayoutBuilder.maxThumbnailAspectRatio,
          );
    } else {
      thumbnailWidth = tileExtent;
    }

    Widget child = ThumbnailImage(
      entry: entry,
      extent: tileExtent,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      isMosaic: isMosaic,
      cancellableNotifier: cancellableNotifier,
      heroTag: heroTagger?.call(),
    );

    child = Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        ThumbnailEntryOverlay(entry: entry),
        if (selectable) ...[
          GridItemSelectionOverlay<AvesEntry>(
            item: entry,
            padding: const EdgeInsets.all(2),
          ),
          ThumbnailZoomOverlay(
            onZoom: () => OpenViewerNotification(entry).dispatch(context),
          ),
        ],
        if (highlightable) ThumbnailHighlightOverlay(entry: entry),
      ],
    );

    return Container(
      // `decoration` with sub logical pixel width yields scintillating borders
      // so we use `foregroundDecoration` instead
      foregroundDecoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
          color: borderColor,
          width: borderWidth(context),
        )),
      ),
      width: thumbnailWidth,
      height: thumbnailHeight,
      child: child,
    );
  }
}
