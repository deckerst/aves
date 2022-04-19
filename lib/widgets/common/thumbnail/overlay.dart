import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailEntryOverlay extends StatelessWidget {
  final AvesEntry entry;

  const ThumbnailEntryOverlay({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      if (entry.isFavourite && context.select<GridThemeData, bool>((t) => t.showFavourite)) const FavouriteIcon(),
      if (entry.hasGps && context.select<GridThemeData, bool>((t) => t.showLocation)) const GpsIcon(),
      if (entry.rating != 0 && context.select<GridThemeData, bool>((t) => t.showRating)) RatingIcon(entry: entry),
      if (entry.isVideo)
        VideoIcon(entry: entry)
      else if (entry.isAnimated)
        const AnimatedImageIcon()
      else ...[
        if (entry.isRaw && context.select<GridThemeData, bool>((t) => t.showRaw)) const RawIcon(),
        if (entry.is360) const SphericalImageIcon(),
      ],
      if (entry.isMultiPage) ...[
        if (entry.isMotionPhoto && context.select<GridThemeData, bool>((t) => t.showMotionPhoto)) const MotionPhotoIcon(),
        if (!entry.isMotionPhoto) MultiPageIcon(entry: entry),
      ],
      if (entry.isGeotiff) const GeoTiffIcon(),
      if (entry.trashed && context.select<GridThemeData, bool>((t) => t.showTrash)) TrashIcon(trashDaysLeft: entry.trashDaysLeft),
    ];
    if (children.isEmpty) return const SizedBox();
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class ThumbnailHighlightOverlay extends StatefulWidget {
  final AvesEntry entry;

  const ThumbnailHighlightOverlay({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<ThumbnailHighlightOverlay> createState() => _ThumbnailHighlightOverlayState();
}

class _ThumbnailHighlightOverlayState extends State<ThumbnailHighlightOverlay> {
  final ValueNotifier<bool> _highlightedNotifier = ValueNotifier(false);

  AvesEntry get entry => widget.entry;

  static const startAngle = pi * -3 / 4;

  @override
  Widget build(BuildContext context) {
    final highlightInfo = context.watch<HighlightInfo>();
    _highlightedNotifier.value = highlightInfo.contains(entry);
    return Sweeper(
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: context.select<GridThemeData, double>((t) => t.highlightBorderWidth),
          )),
        ),
      ),
      toggledNotifier: _highlightedNotifier,
      startAngle: startAngle,
      centerSweep: false,
      onSweepEnd: highlightInfo.clear,
    );
  }
}
