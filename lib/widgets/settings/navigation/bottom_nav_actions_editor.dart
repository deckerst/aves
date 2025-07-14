import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/home/home_page.dart';
import 'package:aves/widgets/navigation/nav_item.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:aves/widgets/settings/navigation/drawer.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';

class BottomNavigationActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/navigation/bottom_actions';

  const BottomNavigationActionEditorPage({super.key});

  static final allAvailableActions = [
    NavigationDrawerEditorPage.collectionFilterOptions.map((filter) {
      return AvesNavItem(
        route: CollectionPage.routeName,
        filters: filter != null ? {filter} : null,
      );
    }).toList(),
    [
      HomePage.routeName,
      SettingsPage.routeName,
      ...NavigationDrawerEditorPage.pageOptions,
    ].map((v) {
      return AvesNavItem(
        route: v,
      );
    }).toList(),
  ];

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<AvesNavItem>(
      title: context.l10n.settingsNavigationBottomActionEditorPageTitle,
      bannerText: context.l10n.settingsNavigationBottomActionEditorBanner,
      allAvailableActions: allAvailableActions,
      actionIcon: (context, action) => action.getIcon(context),
      actionText: (context, action) => action.getText(context),
      load: () => settings.bottomNavigationActions,
      save: (actions) => settings.bottomNavigationActions = actions,
    );
  }
}
