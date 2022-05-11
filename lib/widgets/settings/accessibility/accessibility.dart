import 'dart:async';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/accessibility/time_to_take_action.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessibilitySection extends SettingsSection {
  @override
  String get key => 'accessibility';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.accessibility,
        color: context.select<AvesColorsData, Color>((v) => v.accessibility),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsSectionAccessibility;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        SettingsTileAccessibilityAnimations(),
        SettingsTileAccessibilityTimeToTakeAction(),
      ];
}

class SettingsTileAccessibilityAnimations extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsRemoveAnimationsTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<AccessibilityAnimations>(
        values: AccessibilityAnimations.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.accessibilityAnimations,
        onSelection: (v) => settings.accessibilityAnimations = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsRemoveAnimationsTitle,
      );
}

class SettingsTileAccessibilityTimeToTakeAction extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsTimeToTakeActionTile;

  @override
  Widget build(BuildContext context) => const TimeToTakeActionTile();
}
