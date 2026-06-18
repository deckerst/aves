import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/aves_app.dart';
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
    final l10n = context.l10n;
    return AvesScaffold(
      appBar: AppBar(
        title: Text(l10n.settingsVideoPlaybackPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSelectionListTile<VideoAutoPlayMode>(
              values: VideoAutoPlayMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoAutoPlayMode,
              onSelection: (v) => settings.videoAutoPlayMode = v,
              tileTitle: (_) => l10n.settingsVideoAutoPlay,
            ),
            SettingsSelectionListTile<VideoLoopMode>(
              values: VideoLoopMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoLoopMode,
              onSelection: (v) => settings.videoLoopMode = v,
              tileTitle: (_) => l10n.settingsVideoLoopModeTile,
              dialogTitle: l10n.settingsVideoLoopModeDialogTitle,
            ),
            SettingsSelectionListTile<VideoResumptionMode>(
              values: VideoResumptionMode.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoResumptionMode,
              onSelection: (v) => settings.videoResumptionMode = v,
              tileTitle: (_) => l10n.settingsVideoResumptionModeTile,
              dialogTitle: l10n.settingsVideoResumptionModeDialogTitle,
            ),
            if (!settings.useTvLayout && device.supportPictureInPicture)
              SettingsSelectionListTile<VideoBackgroundMode>(
                values: VideoBackgroundMode.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.videoBackgroundMode,
                onSelection: (v) => settings.videoBackgroundMode = v,
                tileTitle: (_) => l10n.settingsVideoBackgroundMode,
                dialogTitle: l10n.settingsVideoBackgroundModeDialogTitle,
              ),
            SettingsSelectionListTile<VideoHardwareAcceleration>(
              values: VideoHardwareAcceleration.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.videoHardwareAcceleration,
              onSelection: (v) => settings.videoHardwareAcceleration = v,
              tileTitle: (_) => l10n.settingsVideoEnableHardwareAcceleration,
              trailingBuilder: (context) => IconButton(
                icon: const Icon(AIcons.help),
                onPressed: () => AvesApp.launchUrl('${AppReference.avesFaq}#should-i-enable-hardware-acceleration-to-play-videos'),
                tooltip: 'FAQ',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
