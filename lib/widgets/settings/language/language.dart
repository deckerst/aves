import 'dart:async';

import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/poi.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/language/locale_tile.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSection extends SettingsSection {
  @override
  String get key => 'language';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.language,
        color: context.select<AvesColorsData, Color>((v) => v.language),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsLanguageSectionTitle;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) => [
        SettingsTileLanguageLocale(),
        SettingsTileLanguageCoordinateFormat(),
        SettingsTileLanguageUnitSystem(),
      ];
}

class SettingsTileLanguageLocale extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsLanguageTile;

  @override
  Widget build(BuildContext context) => const LocaleTile();
}

class SettingsTileLanguageCoordinateFormat extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsCoordinateFormatTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<CoordinateFormat>(
        values: CoordinateFormat.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.coordinateFormat,
        onSelection: (v) => settings.coordinateFormat = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsCoordinateFormatDialogTitle,
        optionSubtitleBuilder: (value) => value.format(context.l10n, PointsOfInterest.pointNemo),
      );
}

class SettingsTileLanguageUnitSystem extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsUnitSystemTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<UnitSystem>(
        values: UnitSystem.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.unitSystem,
        onSelection: (v) => settings.unitSystem = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsUnitSystemDialogTitle,
      );
}
