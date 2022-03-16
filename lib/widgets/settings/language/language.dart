import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/unit_system.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const LanguageSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesExpansionTile(
      // key is expected by test driver
      key: const Key('section-language'),
      // use a fixed value instead of the title to identify this expansion tile
      // so that the tile state is kept when the language is modified
      value: 'language',
      leading: SettingsTileLeading(
        icon: AIcons.language,
        color: context.select<AvesColorsData, Color>((v) => v.language),
      ),
      title: l10n.settingsSectionLanguage,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        const LocaleTile(),
        SettingsSelectionListTile<CoordinateFormat>(
          values: CoordinateFormat.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.coordinateFormat,
          onSelection: (v) => settings.coordinateFormat = v,
          tileTitle: l10n.settingsCoordinateFormatTile,
          dialogTitle: l10n.settingsCoordinateFormatTitle,
          optionSubtitleBuilder: (value) => value.format(l10n, Constants.pointNemo),
        ),
        SettingsSelectionListTile<UnitSystem>(
          values: UnitSystem.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.unitSystem,
          onSelection: (v) => settings.unitSystem = v,
          tileTitle: l10n.settingsUnitSystemTile,
          dialogTitle: l10n.settingsUnitSystemTitle,
        ),
      ],
    );
  }
}
