import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/flutter_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final bool topLevel;
  final String routeName;
  final WidgetBuilder pageBuilder;

  const NavTile({
    @required this.icon,
    @required this.title,
    this.trailing,
    this.topLevel = true,
    @required this.routeName,
    @required this.pageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        key: Key('$title-tile'),
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing != null
            ? Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: TextStyle(
                    color: IconTheme.of(context).color.withOpacity(.6),
                  ),
                  child: trailing,
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (routeName != context.currentRouteName) {
            final route = MaterialPageRoute(
              settings: RouteSettings(name: routeName),
              builder: pageBuilder,
            );
            if (topLevel) {
              Navigator.pushAndRemoveUntil(
                context,
                route,
                settings.navRemoveRoutePredicate(routeName),
              );
            } else {
              Navigator.push(context, route);
            }
          }
        },
        selected: context.currentRouteName == routeName,
      ),
    );
  }
}
