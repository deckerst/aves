import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';

class PageNavTile extends StatelessWidget {
  final Widget? trailing;
  final bool topLevel;
  final String routeName;

  const PageNavTile({
    super.key,
    this.trailing,
    this.topLevel = true,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: () {
          Navigator.pop(context);
          final route = MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: pageBuilder(routeName),
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
        },
        selected: context.currentRouteName == routeName,
      ),
    );
  }

  static WidgetBuilder pageBuilder(String route) {
    switch (route) {
      case AlbumListPage.routeName:
        return (_) => const AlbumListPage();
      case CountryListPage.routeName:
        return (_) => const CountryListPage();
      case TagListPage.routeName:
        return (_) => const TagListPage();
      case SettingsPage.routeName:
        return (_) => const SettingsPage();
      case AboutPage.routeName:
        return (_) => const AboutPage();
      case AppDebugPage.routeName:
        return (_) => const AppDebugPage();
      default:
        throw Exception('unknown route=$route');
    }
  }
}
