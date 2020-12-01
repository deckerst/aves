import 'dart:math';

import 'package:aves/model/highlight.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
    return Selector<Settings, Tuple3<bool, bool, bool>>(
        selector: (context, s) => Tuple3(s.showThumbnailLocation, s.showThumbnailRaw, s.showThumbnailVideoDuration),
        builder: (context, s, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.hasGps && settings.showThumbnailLocation) GpsIcon(iconSize: iconSize),
              if (entry.isRaw && settings.showThumbnailRaw) RawIcon(iconSize: iconSize),
              if (entry.isGeotiff) GeotiffIcon(iconSize: iconSize),
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
                    showDuration: settings.showThumbnailVideoDuration,
                  ),
                ),
            ],
          );
        });
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
    const duration = Durations.thumbnailOverlayAnimation;
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
  final ImageEntry entry;
  final double extent;

  const ThumbnailHighlightOverlay({
    Key key,
    @required this.entry,
    @required this.extent,
  }) : super(key: key);

  @override
  _ThumbnailHighlightOverlayState createState() => _ThumbnailHighlightOverlayState();
}

class _ThumbnailHighlightOverlayState extends State<ThumbnailHighlightOverlay> {
  final ValueNotifier<bool> _highlightedNotifier = ValueNotifier(false);

  ImageEntry get entry => widget.entry;

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
      startAngle: pi * -3 / 4,
      centerSweep: false,
      onSweepEnd: () => highlightInfo.remove(entry),
    );
  }
}
