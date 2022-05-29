import 'dart:async';

import 'package:aves/model/device.dart';
import 'package:aves/model/settings/enums/display_refresh_rate_mode.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/theme_brightness.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplaySection extends SettingsSection {
  @override
  String get key => 'display';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.display,
        color: context.select<AvesColorsData, Color>((v) => v.display),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsSectionDisplay;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        SettingsTileDisplayThemeBrightness(),
        SettingsTileDisplayThemeColorMode(),
        if (device.isDynamicColorAvailable) SettingsTileDisplayEnableDynamicColor(),
        SettingsTileDisplayEnableBlurEffect(),
        SettingsTileDisplayDisplayRefreshRateMode(),
      ];
}

class SettingsTileDisplayThemeBrightness extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThemeBrightness;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<AvesThemeBrightness>(
        values: AvesThemeBrightness.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.themeBrightness,
        onSelection: (v) => settings.themeBrightness = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsThemeBrightness,
      );
}

class SettingsTileDisplayThemeColorMode extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThemeColorHighlights;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.themeColorMode == AvesThemeColorMode.polychrome,
        onChanged: (v) => settings.themeColorMode = v ? AvesThemeColorMode.polychrome : AvesThemeColorMode.monochrome,
        title: title(context),
      );
}

class SettingsTileDisplayEnableDynamicColor extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThemeEnableDynamicColor;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.enableDynamicColor,
    onChanged: (v) => settings.enableDynamicColor = v,
    title: title(context),
  );
}

class SettingsTileDisplayEnableBlurEffect extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerEnableOverlayBlurEffect;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.enableBlurEffect,
    onChanged: (v) => settings.enableBlurEffect = v,
    title: title(context),
  );
}

class SettingsTileDisplayDisplayRefreshRateMode extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsDisplayRefreshRateModeTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<DisplayRefreshRateMode>(
        values: DisplayRefreshRateMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.displayRefreshRateMode,
        onSelection: (v) => settings.displayRefreshRateMode = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsDisplayRefreshRateModeTitle,
      );
}
