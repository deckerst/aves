import 'dart:math';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChipHighlightOverlay extends StatefulWidget {
  final CollectionFilter filter;
  final double extent;
  final BorderRadius borderRadius;

  const ChipHighlightOverlay({
    Key? key,
    required this.filter,
    required this.extent,
    required this.borderRadius,
  }) : super(key: key);

  @override
  State<ChipHighlightOverlay> createState() => _ChipHighlightOverlayState();
}

class _ChipHighlightOverlayState extends State<ChipHighlightOverlay> {
  final ValueNotifier<bool> _highlightedNotifier = ValueNotifier(false);

  CollectionFilter get filter => widget.filter;

  @override
  Widget build(BuildContext context) {
    final highlightInfo = context.watch<HighlightInfo>();
    _highlightedNotifier.value = highlightInfo.contains(filter);
    return Sweeper(
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: widget.extent * .1,
          )),
          borderRadius: widget.borderRadius,
        ),
      ),
      toggledNotifier: _highlightedNotifier,
      startAngle: pi * -3 / 4,
      centerSweep: false,
      onSweepEnd: highlightInfo.clear,
    );
  }
}
