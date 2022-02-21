import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridTheme extends StatelessWidget {
  final double extent;
  final bool? showLocation, showTrash;
  final Widget child;

  const GridTheme({
    Key? key,
    required this.extent,
    this.showLocation,
    this.showTrash,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<Settings, MediaQueryData, GridThemeData>(
      update: (context, settings, mq, previous) {
        var iconSize = min(24.0, (extent / 5)).roundToDouble();
        final fontSize = (iconSize * .7).floorToDouble();
        iconSize *= mq.textScaleFactor;
        final highlightBorderWidth = extent * .1;
        return GridThemeData(
          iconSize: iconSize,
          fontSize: fontSize,
          highlightBorderWidth: highlightBorderWidth,
          showFavourite: settings.showThumbnailFavourite,
          showLocation: showLocation ?? settings.showThumbnailLocation,
          showMotionPhoto: settings.showThumbnailMotionPhoto,
          showRating: settings.showThumbnailRating,
          showRaw: settings.showThumbnailRaw,
          showTrash: showTrash ?? true,
          showVideoDuration: settings.showThumbnailVideoDuration,
        );
      },
      child: child,
    );
  }
}

class GridThemeData {
  final double iconSize, fontSize, highlightBorderWidth;
  final bool showFavourite, showLocation, showMotionPhoto, showRating, showRaw, showTrash, showVideoDuration;

  const GridThemeData({
    required this.iconSize,
    required this.fontSize,
    required this.highlightBorderWidth,
    required this.showFavourite,
    required this.showLocation,
    required this.showMotionPhoto,
    required this.showRating,
    required this.showRaw,
    required this.showTrash,
    required this.showVideoDuration,
  });
}
