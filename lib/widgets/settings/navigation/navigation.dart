import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/navigation/confirmation_dialogs.dart';
import 'package:aves/widgets/settings/navigation/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const NavigationSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.home,
        color: context.select<AvesColorsData, Color>((v) => v.navigation),
      ),
      title: context.l10n.settingsSectionNavigation,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        SettingsSelectionListTile<HomePageSetting>(
          values: HomePageSetting.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.homePage,
          onSelection: (v) => settings.homePage = v,
          tileTitle: context.l10n.settingsHome,
          dialogTitle: context.l10n.settingsHome,
        ),
        const NavigationDrawerTile(),
        const ConfirmationDialogTile(),
        SettingsSelectionListTile<KeepScreenOn>(
          values: KeepScreenOn.values,
          getName: (context, v) => v.getName(context),
          selector: (context, s) => s.keepScreenOn,
          onSelection: (v) => settings.keepScreenOn = v,
          tileTitle: context.l10n.settingsKeepScreenOnTile,
          dialogTitle: context.l10n.settingsKeepScreenOnTitle,
        ),
        SettingsSwitchListTile(
          selector: (context, s) => s.mustBackTwiceToExit,
          onChanged: (v) => settings.mustBackTwiceToExit = v,
          title: context.l10n.settingsDoubleBackExit,
        ),
      ],
    );
  }
}
