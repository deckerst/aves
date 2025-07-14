import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/navigation/bottom_nav_actions_editor.dart';
import 'package:aves/widgets/settings/navigation/confirmation_dialogs.dart';
import 'package:aves/widgets/settings/navigation/drawer.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
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
  String title(BuildContext context) => context.l10n.settingsNavigationSectionTitle;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        SettingsTileNavigationHomePage(),
        if (!settings.useTvLayout) SettingsTileNavigationKeepScreenOn(),
        if (!settings.useTvLayout) SettingsTileNavigationDoubleBackExit(),
        SettingsTileNavigationDrawer(),
        if (!settings.useTvLayout) SettingsTileNavigationBottomActions(),
        if (!settings.useTvLayout) SettingsTileNavigationConfirmationDialog(),
      ];
}

class _HomeOption {
  final HomePageSetting page;
  final Set<CollectionFilter> customCollection;
  final String? customExplorerPath;

  const _HomeOption(
    this.page, {
    this.customCollection = const {},
    this.customExplorerPath,
  });

  String getName(BuildContext context) {
    final pageName = page.getName(context);
    switch (page) {
      case HomePageSetting.collection:
        return customCollection.isNotEmpty ? context.l10n.setHomeCustom : pageName;
      case HomePageSetting.explorer:
        return customExplorerPath != null ? context.l10n.setHomeCustom : pageName;
      default:
        return pageName;
    }
  }

  String? getDetails(BuildContext context) {
    switch (page) {
      case HomePageSetting.collection:
        final filters = customCollection;
        return filters.isNotEmpty ? [context.l10n.collectionPageTitle, filters.map((v) => v.getLabel(context)).join(', ')].join(AText.separator) : null;
      case HomePageSetting.explorer:
        final path = customExplorerPath;
        return path != null ? [context.l10n.explorerPageTitle, pContext.basename(path)].join(AText.separator) : null;
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is _HomeOption && runtimeType == other.runtimeType && page == other.page && const DeepCollectionEquality().equals(customCollection, other.customCollection) && customExplorerPath == other.customExplorerPath);

  @override
  int get hashCode => page.hashCode ^ customCollection.hashCode ^ customExplorerPath.hashCode;
}

class SettingsTileNavigationHomePage extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsHomeTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<_HomeOption>(
        values: [
          const _HomeOption(HomePageSetting.collection),
          const _HomeOption(HomePageSetting.albums),
          const _HomeOption(HomePageSetting.tags),
          const _HomeOption(HomePageSetting.explorer),
          if (settings.homeCustomCollection.isNotEmpty) _HomeOption(HomePageSetting.collection, customCollection: settings.homeCustomCollection),
          if (settings.homeCustomExplorerPath != null) _HomeOption(HomePageSetting.explorer, customExplorerPath: settings.homeCustomExplorerPath),
        ],
        getName: (context, v) => v.getName(context),
        selector: (context, s) => _HomeOption(s.homePage, customCollection: s.homeCustomCollection, customExplorerPath: s.homeCustomExplorerPath),
        onSelection: (v) => settings.setHome(
          v.page,
          customCollection: v.customCollection,
          customExplorerPath: v.customExplorerPath,
        ),
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsHomeDialogTitle,
        optionSubtitleBuilder: (v) => v.getDetails(context),
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

class SettingsTileNavigationBottomActions extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsNavigationBottomActionsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title(context),
    routeName: BottomNavigationActionEditorPage.routeName,
    builder: (context) => const BottomNavigationActionEditorPage(),
  );
}

class SettingsTileNavigationConfirmationDialog extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsConfirmationTile;

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
        dialogTitle: context.l10n.settingsKeepScreenOnDialogTitle,
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
