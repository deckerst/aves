import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MapNavigationButton { back, map }

class MapTheme extends StatelessWidget {
  final bool interactive;
  final MapNavigationButton navigationButton;
  final VisualDensity? visualDensity;
  final double? mapHeight;
  final Widget child;

  const MapTheme({
    Key? key,
    required this.interactive,
    required this.navigationButton,
    this.visualDensity,
    this.mapHeight,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, MapThemeData>(
      update: (_, settings, __) {
        return MapThemeData(
          interactive: interactive,
          navigationButton: navigationButton,
          visualDensity: visualDensity,
          mapHeight: mapHeight,
          // TODO TLAD use settings?
          // showLocation: showBackButton ?? settings.showThumbnailLocation,
        );
      },
      child: child,
    );
  }
}

class MapThemeData {
  final bool interactive;
  final MapNavigationButton navigationButton;
  final VisualDensity? visualDensity;
  final double? mapHeight;

  const MapThemeData({
    required this.interactive,
    required this.navigationButton,
    this.visualDensity,
    this.mapHeight,
  });
}
