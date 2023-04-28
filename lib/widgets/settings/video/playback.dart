import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class VideoPlaybackPage extends StatelessWidget {
  static const routeName = '/settings/video/playback';

  const VideoPlaybackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsVideoPlaybackPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.enableVideoHardwareAcceleration,
              onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
              title: context.l10n.settingsVideoEnableHardwareAcceleration,
            ),
            SettingsSelectionListTile<VideoAutoPlayMode>(
              values: VideoAutoPlayMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoAutoPlayMode,
              onSelection: (v) => settings.videoAutoPlayMode = v,
              tileTitle: context.l10n.settingsVideoAutoPlay,
            ),
            SettingsSelectionListTile<VideoLoopMode>(
              values: VideoLoopMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoLoopMode,
              onSelection: (v) => settings.videoLoopMode = v,
              tileTitle: context.l10n.settingsVideoLoopModeTile,
              dialogTitle: context.l10n.settingsVideoLoopModeDialogTitle,
            ),
            SettingsSelectionListTile<VideoResumptionMode>(
              values: VideoResumptionMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoResumptionMode,
              onSelection: (v) => settings.videoResumptionMode = v,
              tileTitle: context.l10n.settingsVideoResumptionModeTile,
              dialogTitle: context.l10n.settingsVideoResumptionModeDialogTitle,
            ),
            if (!settings.useTvLayout && device.supportPictureInPicture)
              SettingsSelectionListTile<VideoBackgroundMode>(
                values: VideoBackgroundMode.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.videoBackgroundMode,
                onSelection: (v) => settings.videoBackgroundMode = v,
                tileTitle: context.l10n.settingsVideoBackgroundMode,
                dialogTitle: context.l10n.settingsVideoBackgroundModeDialogTitle,
              ),
          ],
        ),
      ),
    );
  }
}
