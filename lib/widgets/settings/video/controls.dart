import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/video_controls.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class VideoControlsPage extends StatelessWidget {
  static const routeName = '/settings/video/controls';

  const VideoControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsVideoControlsTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSelectionListTile<VideoControls>(
              values: VideoControls.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoControls,
              onSelection: (v) => settings.videoControls = v,
              tileTitle: context.l10n.settingsVideoButtonsTile,
              dialogTitle: context.l10n.settingsVideoButtonsTitle,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureDoubleTapTogglePlay,
              onChanged: (v) => settings.videoGestureDoubleTapTogglePlay = v,
              title: context.l10n.settingsVideoGestureDoubleTapTogglePlay,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureSideDoubleTapSeek,
              onChanged: (v) => settings.videoGestureSideDoubleTapSeek = v,
              title: context.l10n.settingsVideoGestureSideDoubleTapSeek,
            ),
          ],
        ),
      ),
    );
  }
}
