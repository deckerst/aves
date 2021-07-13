import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/privacy/access_grants.dart';
import 'package:aves/widgets/settings/privacy/hidden_filters.dart';
import 'package:aves/widgets/settings/privacy/hidden_paths.dart';
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
    final currentIsCrashlyticsEnabled = context.select<Settings, bool>((s) => s.isCrashlyticsEnabled);
    final currentSaveSearchHistory = context.select<Settings, bool>((s) => s.saveSearchHistory);

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.privacy,
        color: stringToColor('Privacy'),
      ),
      title: context.l10n.settingsSectionPrivacy,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        SwitchListTile(
          value: currentIsCrashlyticsEnabled,
          onChanged: (v) => settings.isCrashlyticsEnabled = v,
          title: Text(context.l10n.settingsEnableCrashReport),
        ),
        SwitchListTile(
          value: currentSaveSearchHistory,
          onChanged: (v) {
            settings.saveSearchHistory = v;
            if (!v) {
              settings.searchHistory = [];
            }
          },
          title: Text(context.l10n.settingsSaveSearchHistory),
        ),
        const HiddenFilterTile(),
        const HiddenPathTile(),
        const StorageAccessTile(),
      ],
    );
  }
}
