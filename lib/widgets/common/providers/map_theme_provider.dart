import 'package:aves/model/settings/settings.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapTheme extends StatelessWidget {
  final bool interactive, showCoordinateFilter;
  final MapNavigationButton navigationButton;
  final Animation<double> scale;
  final VisualDensity visualDensity;
  final double? mapHeight;
  final EdgeInsets attributionPadding;
  final Widget child;

  const MapTheme({
    super.key,
    required this.interactive,
    required this.showCoordinateFilter,
    required this.navigationButton,
    this.scale = kAlwaysCompleteAnimation,
    this.visualDensity = VisualDensity.standard,
    this.mapHeight,
    this.attributionPadding = EdgeInsets.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, MapThemeData>(
      update: (context, settings, __) {
        return MapThemeData(
          interactive: interactive,
          showCoordinateFilter: showCoordinateFilter,
          navigationButton: navigationButton,
          scale: scale,
          visualDensity: visualDensity,
          mapHeight: mapHeight,
          attributionPadding: attributionPadding,
        );
      },
      child: child,
    );
  }
}
