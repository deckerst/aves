import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/privacy/access_grants.dart';
import 'package:aves/widgets/settings/privacy/hidden_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivacySection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const PrivacySection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canEnableErrorReporting = context.select<AppFlavor, bool>((v) => v.canEnableErrorReporting);

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.privacy,
        color: context.select<AvesColorsData, Color>((v) => v.privacy),
      ),
      title: context.l10n.settingsSectionPrivacy,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        SettingsSwitchListTile(
          selector: (context, s) => s.isInstalledAppAccessAllowed,
          onChanged: (v) => settings.isInstalledAppAccessAllowed = v,
          title: context.l10n.settingsAllowInstalledAppAccess,
          subtitle: context.l10n.settingsAllowInstalledAppAccessSubtitle,
        ),
        if (canEnableErrorReporting)
          SettingsSwitchListTile(
            selector: (context, s) => s.isErrorReportingAllowed,
            onChanged: (v) => settings.isErrorReportingAllowed = v,
            title: context.l10n.settingsAllowErrorReporting,
          ),
        SettingsSwitchListTile(
          selector: (context, s) => s.saveSearchHistory,
          onChanged: (v) {
            settings.saveSearchHistory = v;
            if (!v) {
              settings.searchHistory = [];
            }
          },
          title: context.l10n.settingsSaveSearchHistory,
        ),
        SettingsSwitchListTile(
          selector: (context, s) => s.enableBin,
          onChanged: (v) {
            settings.enableBin = v;
            if (!v) {
              settings.searchHistory = [];
            }
          },
          title: context.l10n.settingsEnableBin,
          subtitle: context.l10n.settingsEnableBinSubtitle,
        ),
        const HiddenItemsTile(),
        if (device.canGrantDirectoryAccess) const StorageAccessTile(),
      ],
    );
  }
}
