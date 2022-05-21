import 'dart:async';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/privacy/access_grants.dart';
import 'package:aves/widgets/settings/privacy/hidden_items.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivacySection extends SettingsSection {
  @override
  String get key => 'privacy';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.privacy,
        color: context.select<AvesColorsData, Color>((v) => v.privacy),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsSectionPrivacy;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) async {
    final canEnableErrorReporting = context.select<AppFlavor, bool>((v) => v.canEnableErrorReporting);
    return [
      SettingsTilePrivacyAllowInstalledAppAccess(),
      if (canEnableErrorReporting) SettingsTilePrivacyAllowErrorReporting(),
      SettingsTilePrivacySaveSearchHistory(),
      SettingsTilePrivacyEnableBin(),
      SettingsTilePrivacyHiddenItems(),
      if (device.canGrantDirectoryAccess) SettingsTilePrivacyStorageAccess(),
    ];
  }
}

class SettingsTilePrivacyAllowInstalledAppAccess extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsAllowInstalledAppAccess;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.isInstalledAppAccessAllowed,
        onChanged: (v) => settings.isInstalledAppAccessAllowed = v,
        title: title(context),
        subtitle: context.l10n.settingsAllowInstalledAppAccessSubtitle,
      );
}

class SettingsTilePrivacyAllowErrorReporting extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsAllowErrorReporting;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.isErrorReportingAllowed,
        onChanged: (v) => settings.isErrorReportingAllowed = v,
        title: title(context),
      );
}

class SettingsTilePrivacySaveSearchHistory extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsSaveSearchHistory;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.saveSearchHistory,
        onChanged: (v) {
          settings.saveSearchHistory = v;
          if (!v) {
            settings.searchHistory = [];
          }
        },
        title: title(context),
      );
}

class SettingsTilePrivacyEnableBin extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsEnableBin;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.enableBin,
        onChanged: (v) {
          settings.enableBin = v;
          if (!v) {
            settings.searchHistory = [];
          }
        },
        title: title(context),
        subtitle: context.l10n.settingsEnableBinSubtitle,
      );
}

class SettingsTilePrivacyHiddenItems extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsHiddenItemsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: HiddenItemsPage.routeName,
        builder: (context) => const HiddenItemsPage(),
      );
}

class SettingsTilePrivacyStorageAccess extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsStorageAccessTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: StorageAccessPage.routeName,
        builder: (context) => const StorageAccessPage(),
      );
}
