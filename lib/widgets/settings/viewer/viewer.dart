import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/viewer/entry_background.dart';
import 'package:aves/widgets/settings/viewer/viewer_actions_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const ViewerSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentShowOverlayMinimap = context.select<Settings, bool>((s) => s.showOverlayMinimap);
    final currentShowOverlayInfo = context.select<Settings, bool>((s) => s.showOverlayInfo);
    final currentShowOverlayShootingDetails = context.select<Settings, bool>((s) => s.showOverlayShootingDetails);
    final currentRasterBackground = context.select<Settings, EntryBackground>((s) => s.rasterBackground);
    final currentVectorBackground = context.select<Settings, EntryBackground>((s) => s.vectorBackground);

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.image,
        color: stringToColor('Image'),
      ),
      title: context.l10n.settingsSectionViewer,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        ViewerActionsTile(),
        SwitchListTile(
          value: currentShowOverlayMinimap,
          onChanged: (v) => settings.showOverlayMinimap = v,
          title: Text(context.l10n.settingsViewerShowMinimap),
        ),
        SwitchListTile(
          value: currentShowOverlayInfo,
          onChanged: (v) => settings.showOverlayInfo = v,
          title: Text(context.l10n.settingsViewerShowInformation),
          subtitle: Text(context.l10n.settingsViewerShowInformationSubtitle),
        ),
        SwitchListTile(
          value: currentShowOverlayShootingDetails,
          onChanged: currentShowOverlayInfo ? (v) => settings.showOverlayShootingDetails = v : null,
          title: Text(context.l10n.settingsViewerShowShootingDetails),
        ),
        ListTile(
          title: Text(context.l10n.settingsRasterImageBackground),
          trailing: EntryBackgroundSelector(
            getter: () => currentRasterBackground,
            setter: (value) => settings.rasterBackground = value,
          ),
        ),
        ListTile(
          title: Text(context.l10n.settingsVectorImageBackground),
          trailing: EntryBackgroundSelector(
            getter: () => currentVectorBackground,
            setter: (value) => settings.vectorBackground = value,
          ),
        ),
      ],
    );
  }
}
