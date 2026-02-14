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
      update: (context, settings, _) {
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

  static Widget heroFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final pushing = flightDirection == HeroFlightDirection.push;
    final fromMediaQuery = MediaQuery.of(fromHeroContext);
    final toMediaQuery = MediaQuery.of(toHeroContext);
    final fromRenderBox = fromHeroContext.findRenderObject()! as RenderBox;
    final toRenderBox = toHeroContext.findRenderObject()! as RenderBox;
    final fromTheme = fromHeroContext.read<MapThemeData>();
    final toTheme = toHeroContext.read<MapThemeData>();

    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = pushing ? animation.value : 1 - animation.value;
          return MapTheme(
            interactive: false,
            showCoordinateFilter: false,
            navigationButton: toTheme.navigationButton,
            visualDensity: VisualDensity.lerp(fromTheme.visualDensity, toTheme.visualDensity, t),
            child: MediaQuery(
              data: toMediaQuery.copyWith(
                padding: EdgeInsets.lerp(fromMediaQuery.padding, toMediaQuery.padding, t),
                viewPadding: EdgeInsets.lerp(fromMediaQuery.viewPadding, toMediaQuery.viewPadding, t),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox.fromSize(
                  size: Size.lerp(fromRenderBox.size, toRenderBox.size, t),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: toHeroContext.widget,
      ),
    );
  }
}
