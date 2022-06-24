import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/slideshow_interval.dart';
import 'package:aves/model/settings/enums/slideshow_video_playback.dart';
import 'package:aves/model/settings/enums/viewer_transition.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class ScreenSaverSettingsPage extends StatelessWidget {
  static const routeName = '/settings/screen_saver';

  const ScreenSaverSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsScreenSaverTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSelectionListTile<ViewerTransition>(
              values: ViewerTransition.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.screenSaverTransition,
              onSelection: (v) => settings.screenSaverTransition = v,
              tileTitle: context.l10n.settingsSlideshowTransitionTile,
              dialogTitle: context.l10n.settingsSlideshowTransitionTitle,
            ),
            SettingsSelectionListTile<SlideshowInterval>(
              values: SlideshowInterval.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.screenSaverInterval,
              onSelection: (v) => settings.screenSaverInterval = v,
              tileTitle: context.l10n.settingsSlideshowIntervalTile,
              dialogTitle: context.l10n.settingsSlideshowIntervalTitle,
            ),
            SettingsSelectionListTile<SlideshowVideoPlayback>(
              values: SlideshowVideoPlayback.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.screenSaverVideoPlayback,
              onSelection: (v) => settings.screenSaverVideoPlayback = v,
              tileTitle: context.l10n.settingsSlideshowVideoPlaybackTile,
              dialogTitle: context.l10n.settingsSlideshowVideoPlaybackTitle,
            ),
          ],
        ),
      ),
    );
  }
}
