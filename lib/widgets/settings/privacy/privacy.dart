import 'package:aves/app_flavor.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
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
        color: stringToColor('Privacy'),
      ),
      title: context.l10n.settingsSectionPrivacy,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        Selector<Settings, bool>(
          selector: (context, s) => s.isInstalledAppAccessAllowed,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.isInstalledAppAccessAllowed = v,
            title: Text(context.l10n.settingsAllowInstalledAppAccess),
            subtitle: Text(context.l10n.settingsAllowInstalledAppAccessSubtitle),
          ),
        ),
        if (canEnableErrorReporting)
          Selector<Settings, bool>(
            selector: (context, s) => s.isErrorReportingAllowed,
            builder: (context, current, child) => SwitchListTile(
              value: current,
              onChanged: (v) => settings.isErrorReportingAllowed = v,
              title: Text(context.l10n.settingsAllowErrorReporting),
            ),
          ),
        Selector<Settings, bool>(
          selector: (context, s) => s.saveSearchHistory,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) {
              settings.saveSearchHistory = v;
              if (!v) {
                settings.searchHistory = [];
              }
            },
            title: Text(context.l10n.settingsSaveSearchHistory),
          ),
        ),
        const HiddenItemsTile(),
        const StorageAccessTile(),
      ],
    );
  }
}
