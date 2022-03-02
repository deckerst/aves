import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
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
    final currentHomePage = context.select<Settings, HomePageSetting>((s) => s.homePage);
    final currentKeepScreenOn = context.select<Settings, KeepScreenOn>((s) => s.keepScreenOn);
    final currentMustBackTwiceToExit = context.select<Settings, bool>((s) => s.mustBackTwiceToExit);

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.home,
        color: AColors.navigation,
      ),
      title: context.l10n.settingsSectionNavigation,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        ListTile(
          title: Text(context.l10n.settingsHome),
          subtitle: Text(currentHomePage.getName(context)),
          onTap: () => showSelectionDialog<HomePageSetting>(
            context: context,
            builder: (context) => AvesSelectionDialog<HomePageSetting>(
              initialValue: currentHomePage,
              options: Map.fromEntries(HomePageSetting.values.map((v) => MapEntry(v, v.getName(context)))),
              title: context.l10n.settingsHome,
            ),
            onSelection: (v) => settings.homePage = v,
          ),
        ),
        const NavigationDrawerTile(),
        const ConfirmationDialogTile(),
        ListTile(
          title: Text(context.l10n.settingsKeepScreenOnTile),
          subtitle: Text(currentKeepScreenOn.getName(context)),
          onTap: () => showSelectionDialog<KeepScreenOn>(
            context: context,
            builder: (context) => AvesSelectionDialog<KeepScreenOn>(
              initialValue: currentKeepScreenOn,
              options: Map.fromEntries(KeepScreenOn.values.map((v) => MapEntry(v, v.getName(context)))),
              title: context.l10n.settingsKeepScreenOnTitle,
            ),
            onSelection: (v) => settings.keepScreenOn = v,
          ),
        ),
        SwitchListTile(
          value: currentMustBackTwiceToExit,
          onChanged: (v) => settings.mustBackTwiceToExit = v,
          title: Text(context.l10n.settingsDoubleBackExit),
        ),
      ],
    );
  }
}
