import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailTheme extends StatelessWidget {
  final double extent;
  final bool? showLocation;
  final Widget child;

  const ThumbnailTheme({
    required this.extent,
    this.showLocation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, ThumbnailThemeData>(
      update: (_, settings, __) {
        final iconSize = min(28.0, (extent / 4)).roundToDouble();
        final fontSize = (iconSize / 2).floorToDouble();
        final highlightBorderWidth = extent * .1;
        return ThumbnailThemeData(
          iconSize: iconSize,
          fontSize: fontSize,
          highlightBorderWidth: highlightBorderWidth,
          showLocation: showLocation ?? settings.showThumbnailLocation,
          showRaw: settings.showThumbnailRaw,
          showVideoDuration: settings.showThumbnailVideoDuration,
        );
      },
      child: child,
    );
  }
}

class ThumbnailThemeData {
  final double iconSize, fontSize, highlightBorderWidth;
  final bool showLocation, showRaw, showVideoDuration;

  const ThumbnailThemeData({
    required this.iconSize,
    required this.fontSize,
    required this.highlightBorderWidth,
    required this.showLocation,
    required this.showRaw,
    required this.showVideoDuration,
  });
}
