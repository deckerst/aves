import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/highlight.dart';
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
