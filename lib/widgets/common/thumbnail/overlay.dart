import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailEntryOverlay extends StatelessWidget {
  final AvesEntry entry;

  const ThumbnailEntryOverlay({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final iconBuilder = context.select<GridThemeData, GridThemeIconBuilder>((t) => t.iconBuilder);
    final children = iconBuilder(context, entry);
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
    super.key,
    required this.entry,
  });

  @override
  State<ThumbnailHighlightOverlay> createState() => _ThumbnailHighlightOverlayState();
}

class _ThumbnailHighlightOverlayState extends State<ThumbnailHighlightOverlay> {
  final ValueNotifier<bool> _highlightedNotifier = ValueNotifier(false);

  AvesEntry get entry => widget.entry;

  static const startAngle = pi * -3 / 4;

  @override
  void dispose() {
    _highlightedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightInfo = context.watch<HighlightInfo>();
    _highlightedNotifier.value = highlightInfo.contains(entry);
    return Sweeper(
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
            color: Theme.of(context).colorScheme.primary,
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

class ThumbnailZoomOverlay extends StatelessWidget {
  final VoidCallback? onZoom;

  const ThumbnailZoomOverlay({
    super.key,
    this.onZoom,
  });

  static const alignment = AlignmentDirectional.bottomEnd;

  @override
  Widget build(BuildContext context) {
    final duration = context.select<DurationsData, Duration>((v) => v.formTransition);
    final isSelecting = context.select<Selection<AvesEntry>, bool>((selection) => selection.isSelecting);
    final interactiveDimension = context.select<GridThemeData, double>((t) => t.interactiveDimension);
    return AnimatedSwitcher(
      duration: duration,
      child: isSelecting
          ? Align(
              alignment: alignment,
              child: GestureDetector(
                onTap: onZoom,
                child: Container(
                  alignment: alignment,
                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                  width: interactiveDimension,
                  height: interactiveDimension,
                  child: Icon(
                    AIcons.showFullscreenArrows,
                    size: context.select<GridThemeData, double>((t) => t.iconSize),
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
