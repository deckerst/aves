import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MapNavigationButton { back, map }

class MapTheme extends StatelessWidget {
  final bool interactive;
  final MapNavigationButton navigationButton;
  final Animation<double> scale;
  final VisualDensity? visualDensity;
  final double? mapHeight;
  final Widget child;

  const MapTheme({
    Key? key,
    required this.interactive,
    required this.navigationButton,
    this.scale = kAlwaysCompleteAnimation,
    this.visualDensity,
    this.mapHeight,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, MapThemeData>(
      update: (context, settings, __) {
        return MapThemeData(
          interactive: interactive,
          navigationButton: navigationButton,
          scale: scale,
          visualDensity: visualDensity,
          mapHeight: mapHeight,
        );
      },
      child: child,
    );
  }
}

class MapThemeData {
  final bool interactive;
  final MapNavigationButton navigationButton;
  final Animation<double> scale;
  final VisualDensity? visualDensity;
  final double? mapHeight;

  const MapThemeData({
    required this.interactive,
    required this.navigationButton,
    required this.scale,
    required this.visualDensity,
    required this.mapHeight,
  });
}
