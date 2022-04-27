import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerOverlayPage extends StatelessWidget {
  static const routeName = '/settings/viewer_overlay';

  const ViewerOverlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsViewerOverlayTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayOnOpening,
              onChanged: (v) => settings.showOverlayOnOpening = v,
              title: context.l10n.settingsViewerShowOverlayOnOpening,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayInfo,
              onChanged: (v) => settings.showOverlayInfo = v,
              title: context.l10n.settingsViewerShowInformation,
              subtitle: context.l10n.settingsViewerShowInformationSubtitle,
            ),
            Selector<Settings, Tuple2<bool, bool>>(
              selector: (context, s) => Tuple2(s.showOverlayInfo, s.showOverlayShootingDetails),
              builder: (context, s, child) {
                final showInfo = s.item1;
                final current = s.item2;
                return SwitchListTile(
                  value: current,
                  onChanged: showInfo ? (v) => settings.showOverlayShootingDetails = v : null,
                  title: Text(context.l10n.settingsViewerShowShootingDetails),
                );
              },
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayMinimap,
              onChanged: (v) => settings.showOverlayMinimap = v,
              title: context.l10n.settingsViewerShowMinimap,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayThumbnailPreview,
              onChanged: (v) => settings.showOverlayThumbnailPreview = v,
              title: context.l10n.settingsViewerShowOverlayThumbnails,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.enableOverlayBlurEffect,
              onChanged: (v) => settings.enableOverlayBlurEffect = v,
              title: context.l10n.settingsViewerEnableOverlayBlurEffect,
            ),
          ],
        ),
      ),
    );
  }
}
