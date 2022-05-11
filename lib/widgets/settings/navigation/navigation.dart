import 'dart:async';

import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/navigation/confirmation_dialogs.dart';
import 'package:aves/widgets/settings/navigation/drawer.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationSection extends SettingsSection {
  @override
  String get key => 'navigation';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.home,
        color: context.select<AvesColorsData, Color>((v) => v.navigation),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsSectionNavigation;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        SettingsTileNavigationHomePage(),
        SettingsTileShowBottomNavigationBar(),
        SettingsTileNavigationDrawer(),
        SettingsTileNavigationConfirmationDialog(),
        SettingsTileNavigationKeepScreenOn(),
        SettingsTileNavigationDoubleBackExit(),
      ];
}

class SettingsTileNavigationHomePage extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsHome;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<HomePageSetting>(
        values: HomePageSetting.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.homePage,
        onSelection: (v) => settings.homePage = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsHome,
      );
}

class SettingsTileShowBottomNavigationBar extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsShowBottomNavigationBar;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.showBottomNavigationBar,
        onChanged: (v) => settings.showBottomNavigationBar = v,
        title: title(context),
      );
}

class SettingsTileNavigationDrawer extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsNavigationDrawerTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: NavigationDrawerEditorPage.routeName,
        builder: (context) => const NavigationDrawerEditorPage(),
      );
}

class SettingsTileNavigationConfirmationDialog extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsConfirmationDialogTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: ConfirmationDialogPage.routeName,
        builder: (context) => const ConfirmationDialogPage(),
      );
}

class SettingsTileNavigationKeepScreenOn extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsKeepScreenOnTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<KeepScreenOn>(
        values: KeepScreenOn.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.keepScreenOn,
        onSelection: (v) => settings.keepScreenOn = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsKeepScreenOnTitle,
      );
}

class SettingsTileNavigationDoubleBackExit extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsDoubleBackExit;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.mustBackTwiceToExit,
        onChanged: (v) => settings.mustBackTwiceToExit = v,
        title: title(context),
      );
}
