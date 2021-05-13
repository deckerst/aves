import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/thumbnail/theme.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailEntryOverlay extends StatelessWidget {
  final AvesEntry entry;
  final double extent;

  const ThumbnailEntryOverlay({
    Key? key,
    required this.entry,
    required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      if (entry.hasGps && context.select<ThumbnailThemeData, bool>((t) => t.showLocation)) GpsIcon(),
      if (entry.isVideo)
        VideoIcon(
          entry: entry,
        )
      else if (entry.isAnimated)
        AnimatedImageIcon()
      else ...[
        if (entry.isRaw && context.select<ThumbnailThemeData, bool>((t) => t.showRaw)) RawIcon(),
        if (entry.isMultiPage) MultiPageIcon(entry: entry),
        if (entry.isGeotiff) GeotiffIcon(),
        if (entry.is360) SphericalImageIcon(),
      ]
    ];
    if (children.isEmpty) return SizedBox.shrink();
    if (children.length == 1) return children.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class ThumbnailSelectionOverlay extends StatelessWidget {
  final AvesEntry entry;
  final double extent;

  static const duration = Durations.thumbnailOverlayAnimation;

  const ThumbnailSelectionOverlay({
    Key? key,
    required this.entry,
    required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionLens>();
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        final child = collection.isSelecting
            ? AnimatedBuilder(
                animation: collection.selectionChangeNotifier,
                builder: (context, child) {
                  final selected = collection.isSelected([entry]);
                  var child = collection.isSelecting
                      ? OverlayIcon(
                          key: ValueKey(selected),
                          icon: selected ? AIcons.selected : AIcons.unselected,
                          size: context.select<ThumbnailThemeData, double>((t) => t.iconSize),
                        )
                      : SizedBox.shrink();
                  child = AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: child,
                  );
                  child = AnimatedContainer(
                    duration: duration,
                    alignment: AlignmentDirectional.topEnd,
                    color: selected ? Colors.black54 : Colors.transparent,
                    child: child,
                  );
                  return child;
                },
              )
            : SizedBox.shrink();
        return AnimatedSwitcher(
          duration: duration,
          child: child,
        );
      },
    );
  }
}

class ThumbnailHighlightOverlay extends StatefulWidget {
  final AvesEntry entry;
  final double extent;

  const ThumbnailHighlightOverlay({
    Key? key,
    required this.entry,
    required this.extent,
  }) : super(key: key);

  @override
  _ThumbnailHighlightOverlayState createState() => _ThumbnailHighlightOverlayState();
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
          border: Border.all(
            color: Theme.of(context).accentColor,
            width: widget.extent * .1,
          ),
        ),
      ),
      toggledNotifier: _highlightedNotifier,
      startAngle: startAngle,
      centerSweep: false,
      onSweepEnd: highlightInfo.clear,
    );
  }
}
