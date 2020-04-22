import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
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
    final fontSize = min(14.0, (extent / 8));
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
    final fontSize = min(14.0, (extent / 8));
    final iconSize = fontSize * 2;
    final collection = Provider.of<CollectionLens>(context);
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        final child = collection.isSelecting
            ? AnimatedBuilder(
                animation: collection.selectionChangeNotifier,
                builder: (context, child) {
                  return OverlayIcon(
                    icon: collection.selection.contains(entry) ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                    size: iconSize,
                  );
                },
              )
            : const SizedBox.shrink();
        return AnimatedSwitcher(
          duration: Duration(milliseconds: (300 * timeDilation).toInt()),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeOutBack,
          transitionBuilder: (child, animation) => ScaleTransition(
            child: child,
            scale: animation,
          ),
          child: child,
        );
      },
    );
  }
}
