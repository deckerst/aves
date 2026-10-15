import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/navigation/nav_display.dart';
import 'package:material_ui/material_ui.dart';

class const DrawerFilterIcon({
  super.key,
  required final CollectionFilter? filter,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = textScaler.scale(24);

    final _filter = filter;
    if (_filter == null) return Icon(AIcons.allCollection, size: iconSize);
    return _filter.iconBuilder(context, iconSize) ?? const SizedBox();
  }
}

class const DrawerFilterTitle({
  super.key,
  required final CollectionFilter? filter,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(NavigationDisplay.getFilterTitle(context, filter));
}

class const DrawerPageIcon({
  super.key,
  required final String route,
}) extends StatelessWidget {
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

class const DrawerPageTitle({
  super.key,
  required final String route,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(NavigationDisplay.getPageTitle(context, route));
}
