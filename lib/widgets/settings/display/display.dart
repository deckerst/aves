import 'dart:async';

import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/privacy/privacy.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves_model/aves_model.dart';
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
  String title(BuildContext context) => context.l10n.settingsDisplaySectionTitle;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        if (!settings.useTvLayout) SettingsTileDisplayThemeBrightness(),
        SettingsTileDisplayThemeColorMode(),
        if (device.isDynamicColorAvailable) SettingsTileDisplayEnableDynamicColor(),
        SettingsTileDisplayEnableBlurEffect(),
        if (!settings.useTvLayout) SettingsTileDisplayRefreshRateMode(),
        if (!device.isTelevision) SettingsTileDisplayForceTvLayout(),
      ];
}

class SettingsTileDisplayThemeBrightness extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThemeBrightnessTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<AvesThemeBrightness>(
        values: AvesThemeBrightness.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.themeBrightness,
        onSelection: (v) => settings.themeBrightness = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsThemeBrightnessDialogTitle,
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

class SettingsTileDisplayRefreshRateMode extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsDisplayRefreshRateModeTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<DisplayRefreshRateMode>(
        values: DisplayRefreshRateMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.displayRefreshRateMode,
        onSelection: (v) => settings.displayRefreshRateMode = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsDisplayRefreshRateModeDialogTitle,
      );
}

class SettingsTileDisplayForceTvLayout extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsDisplayUseTvInterface;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.forceTvLayout,
        onChanged: (v) async {
          if (v) {
            final l10n = context.l10n;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AvesDialog(
                content: Text([
                  l10n.settingsModificationWarningDialogMessage,
                  l10n.genericDangerWarningDialogMessage,
                ].join('\n\n')),
                actions: [
                  const CancelButton(),
                  TextButton(
                    onPressed: () => Navigator.maybeOf(context)?.pop(true),
                    child: Text(l10n.applyButtonLabel),
                  ),
                ],
              ),
            );
            if (confirmed == null || !confirmed) return;
          }

          if (v && !(await SettingsTilePrivacyEnableBin.setBinUsage(context, false))) return;

          settings.forceTvLayout = v;
        },
        title: title(context),
      );
}
