import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/theme_brightness.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplaySection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const DisplaySection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.display,
        color: context.select<AvesColorsData, Color>((v) => v.display),
      ),
      title: context.l10n.settingsSectionDisplay,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        SettingsSelectionListTile<AvesThemeBrightness>(
          values: AvesThemeBrightness.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.themeBrightness,
          onSelection: (v) => settings.themeBrightness = v,
          tileTitle: context.l10n.settingsThemeBrightness,
          dialogTitle: context.l10n.settingsThemeBrightness,
        ),
        SettingsSwitchListTile(
          selector: (context, s) => s.themeColorMode == AvesThemeColorMode.polychrome,
          onChanged: (v) => settings.themeColorMode = v ? AvesThemeColorMode.polychrome : AvesThemeColorMode.monochrome,
          title: context.l10n.settingsThemeColorful,
        ),
      ],
    );
  }
}
