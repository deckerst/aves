import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class VideoControlsPage extends StatelessWidget {
  static const routeName = '/settings/video/controls';

  const VideoControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsVideoControlsPageTitle),
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
            SettingsSwitchListTile(
              selector: (context, s) => s.videoGestureVerticalDragBrightnessVolume,
              onChanged: (v) => settings.videoGestureVerticalDragBrightnessVolume = v,
              title: context.l10n.settingsVideoGestureVerticalDragBrightnessVolume,
            ),
          ],
        ),
      ),
    );
  }
}
