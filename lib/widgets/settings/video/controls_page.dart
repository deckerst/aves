import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/video/control_buttons_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';

class VideoControlsPage extends StatelessWidget {
  static const routeName = '/settings/video/controls';

  static const List<String> settingKeys = [
    ...VideoControlButtonsPage.settingKeys,
    SettingKeys.videoGestureDoubleTapTogglePlayKey,
    SettingKeys.videoGestureSideDoubleTapSeekKey,
    SettingKeys.videoGestureVerticalDragBrightnessVolumeKey,
  ];

  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesScaffold(
      appBar: AppBar(
        title: Text(l10n.settingsVideoControlsPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSubPageTile(
              title: (_) => l10n.settingsVideoButtonsTile,
              routeName: VideoControlButtonsPage.routeName,
              builder: (context) => const VideoControlButtonsPage(),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureDoubleTapTogglePlay,
              onChanged: (v) => settings.videoGestureDoubleTapTogglePlay = v,
              title: (_) => l10n.settingsVideoGestureDoubleTapTogglePlay,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureSideDoubleTapSeek,
              onChanged: (v) => settings.videoGestureSideDoubleTapSeek = v,
              title: (_) => l10n.settingsVideoGestureSideDoubleTapSeek,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureVerticalDragBrightnessVolume,
              onChanged: (v) => settings.videoGestureVerticalDragBrightnessVolume = v,
              title: (_) => l10n.settingsVideoGestureVerticalDragBrightnessVolume,
            ),
          ],
        ),
      ),
    );
  }
}
