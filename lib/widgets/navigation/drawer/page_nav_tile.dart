import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:flutter/material.dart';

class PageNavTile extends StatelessWidget {
  final Widget? trailing;
  final bool topLevel;
  final String routeName;
  final WidgetBuilder? pageBuilder;

  const PageNavTile({
    super.key,
    this.trailing,
    this.topLevel = true,
    required this.routeName,
    required this.pageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final _pageBuilder = pageBuilder;
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        // key is expected by test driver
        key: Key('$routeName-tile'),
        leading: DrawerPageIcon(route: routeName),
        title: DrawerPageTitle(route: routeName),
        trailing: trailing != null
            ? Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: TextStyle(
                    color: IconTheme.of(context).color!.withOpacity(.6),
                  ),
                  child: trailing!,
                ),
              )
            : null,
        onTap: _pageBuilder != null
            ? () {
                Navigator.pop(context);
                final route = MaterialPageRoute(
                  settings: RouteSettings(name: routeName),
                  builder: _pageBuilder,
                );
                if (topLevel) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    route,
                    (route) => false,
                  );
                } else {
                  Navigator.push(context, route);
                }
              }
            : null,
        selected: context.currentRouteName == routeName,
      ),
    );
  }
}
