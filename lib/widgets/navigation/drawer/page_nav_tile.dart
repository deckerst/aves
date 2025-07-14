import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/navigation/nav_item.dart';
import 'package:flutter/material.dart';

typedef TileRouteBuilder = Route Function(BuildContext context, String routeName, bool topLevel);

class PageNavTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final AvesNavItem navItem;
  final bool Function()? isSelected;

  const PageNavTile({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    required this.navItem,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final routeName = navItem.route;
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        // key is expected by test driver
        key: Key('$routeName-tile'),
        leading: leading ?? DrawerPageIcon(route: routeName),
        title: title ?? DrawerPageTitle(route: routeName),
        trailing: trailing != null
            ? Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: TextStyle(
                    color: IconTheme.of(context).color!.withValues(alpha: .6),
                  ),
                  child: trailing!,
                ),
              )
            : null,
        onTap: () {
          Navigator.maybeOf(context)?.pop();
          navItem.goTo(context);
        },
        selected: context.currentRouteName == routeName && (isSelected?.call() ?? true),
      ),
    );
  }
}
