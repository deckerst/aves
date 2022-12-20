import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/navigation/nav_display.dart';
import 'package:flutter/material.dart';

class DrawerFilterIcon extends StatelessWidget {
  final CollectionFilter? filter;

  const DrawerFilterIcon({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = 24 * textScaleFactor;

    final _filter = filter;
    if (_filter == null) return Icon(AIcons.allCollection, size: iconSize);
    return _filter.iconBuilder(context, iconSize) ?? const SizedBox();
  }
}

class DrawerFilterTitle extends StatelessWidget {
  final CollectionFilter? filter;

  const DrawerFilterTitle({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) => Text(NavigationDisplay.getFilterTitle(context, filter));
}

class DrawerPageIcon extends StatelessWidget {
  final String route;

  const DrawerPageIcon({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final icon = NavigationDisplay.getPageIcon(route);
    if (icon != null) {
      switch (route) {
        case AppDebugPage.routeName:
          return ShaderMask(
            shaderCallback: AvesColorsData.debugGradient.createShader,
            blendMode: BlendMode.srcIn,
            child: Icon(icon),
          );
        default:
          return Icon(icon);
      }
    }
    return const SizedBox();
  }
}

class DrawerPageTitle extends StatelessWidget {
  final String route;

  const DrawerPageTitle({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) => Text(NavigationDisplay.getPageTitle(context, route));
}
