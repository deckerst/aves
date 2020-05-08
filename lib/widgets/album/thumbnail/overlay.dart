import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ThumbnailEntryOverlay extends StatelessWidget {
  final ImageEntry entry;
  final double extent;

  const ThumbnailEntryOverlay({
    Key key,
    @required this.entry,
    @required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = min(14.0, (extent / 8)).roundToDouble();
    final iconSize = fontSize * 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.hasGps) GpsIcon(iconSize: iconSize),
        if (entry.isAnimated)
          AnimatedImageIcon(iconSize: iconSize)
        else if (entry.isVideo)
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: fontSize,
            ),
            child: VideoIcon(
              entry: entry,
              iconSize: iconSize,
            ),
          ),
      ],
    );
  }
}

class ThumbnailSelectionOverlay extends StatelessWidget {
  final ImageEntry entry;
  final double extent;

  const ThumbnailSelectionOverlay({
    Key key,
    @required this.entry,
    @required this.extent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: (200 * timeDilation).toInt());
    final fontSize = min(14.0, (extent / 8)).roundToDouble();
    final iconSize = fontSize * 2;
    final collection = Provider.of<CollectionLens>(context);
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
                          size: iconSize,
                        )
                      : const SizedBox.shrink();
                  child = AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      child: child,
                      scale: animation,
                    ),
                    child: child,
                  );
                  child = AnimatedContainer(
                    duration: duration,
                    alignment: Alignment.topRight,
                    color: selected ? Colors.black54 : Colors.transparent,
                    child: child,
                  );
                  return child;
                },
              )
            : const SizedBox.shrink();
        return AnimatedSwitcher(
          duration: duration,
          child: child,
        );
      },
    );
  }
}

class ThumbnailHighlightOverlay extends StatefulWidget {
  final double extent;
  final Stream<bool> highlightedStream;

  const ThumbnailHighlightOverlay({
    Key key,
    @required this.extent,
    @required this.highlightedStream,
  }) : super(key: key);

  @override
  _ThumbnailHighlightOverlayState createState() => _ThumbnailHighlightOverlayState();
}

class _ThumbnailHighlightOverlayState extends State<ThumbnailHighlightOverlay> {
  final ValueNotifier<bool> _highlightedNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.highlightedStream,
      builder: (context, snapshot) {
        _highlightedNotifier.value = snapshot.hasData && snapshot.data;
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
          onSweepEnd: () => _highlightedNotifier.value = false,
        );
      },
    );
  }
}
