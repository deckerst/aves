import 'dart:async';

import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/poi.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/locale/aves_locale.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/language/locale_tile.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
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
  Future<List<SettingsTile>> tiles(BuildContext context) => Future.value([
    SettingsTileLanguageLocale(),
    SettingsTileLanguageCalendar(),
    SettingsTileLanguageCoordinateFormat(),
    SettingsTileLanguageUnitSystem(),
    SettingsTileLanguageNumerals(),
  ]);
}

class SettingsTileLanguageLocale extends SettingsTile {
  @override
  List<String> get settingKeys => LocaleTile.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsLanguageTile;

  @override
  Widget build(BuildContext context) => const LocaleTile();
}

class SettingsTileLanguageCalendar extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.calendarKey];

  @override
  String title(BuildContext context) => context.l10n.settingsCalendarTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<ACalendar>(
    values: const [.gregorian, .persian],
    getName: (context, v) => v.getName(context),
    selector: (context, s) => s.calendar,
    onSelection: (v) => settings.calendar = v,
    tileTitle: title,
    optionSubtitleBuilder: (v) {
      final locale = settings.avesLocale.copyWith(calendar: v);
      return locale.yMMMMd(DateTime.now());
    },
  );
}

class SettingsTileLanguageCoordinateFormat extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.coordinateFormatKey];

  @override
  String title(BuildContext context) => context.l10n.settingsCoordinateFormatTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<CoordinateFormat>(
    values: CoordinateFormat.values,
    getName: (context, v) => v.getName(context),
    selector: (context, s) => s.coordinateFormat,
    onSelection: (v) => settings.coordinateFormat = v,
    tileTitle: title,
    dialogTitle: context.l10n.settingsCoordinateFormatDialogTitle,
    optionSubtitleBuilder: (value) => value.format(context, PointsOfInterest.pointNemo),
  );
}

class SettingsTileLanguageUnitSystem extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.unitSystemKey];

  @override
  String title(BuildContext context) => context.l10n.settingsUnitSystemTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<UnitSystem>(
    values: UnitSystem.values,
    getName: (context, v) => v.getName(context),
    selector: (context, s) => s.unitSystem,
    onSelection: (v) => settings.unitSystem = v,
    tileTitle: title,
    dialogTitle: context.l10n.settingsUnitSystemDialogTitle,
  );
}

class SettingsTileLanguageNumerals extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.forceWesternArabicNumeralsKey];

  @override
  String title(BuildContext context) => context.l10n.settingsForceWesternArabicNumeralsTile;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.forceWesternArabicNumerals,
    onChanged: (v) => settings.forceWesternArabicNumerals = v,
    title: title,
  );
}
