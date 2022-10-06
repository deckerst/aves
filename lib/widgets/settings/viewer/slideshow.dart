import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/slideshow_interval.dart';
import 'package:aves/model/settings/enums/slideshow_video_playback.dart';
import 'package:aves/model/settings/enums/viewer_transition.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class ViewerSlideshowPage extends StatelessWidget {
  static const routeName = '/settings/viewer/slideshow';

  const ViewerSlideshowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsViewerSlideshowPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowRepeat,
              onChanged: (v) => settings.slideshowRepeat = v,
              title: context.l10n.settingsSlideshowRepeat,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowShuffle,
              onChanged: (v) => settings.slideshowShuffle = v,
              title: context.l10n.settingsSlideshowShuffle,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowFillScreen,
              onChanged: (v) => settings.slideshowFillScreen = v,
              title: context.l10n.settingsSlideshowFillScreen,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowAnimatedZoomEffect,
              onChanged: (v) => settings.slideshowAnimatedZoomEffect = v,
              title: context.l10n.settingsSlideshowAnimatedZoomEffect,
            ),
            SettingsSelectionListTile<ViewerTransition>(
              values: ViewerTransition.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowTransition,
              onSelection: (v) => settings.slideshowTransition = v,
              tileTitle: context.l10n.settingsSlideshowTransitionTile,
            ),
            SettingsSelectionListTile<SlideshowInterval>(
              values: SlideshowInterval.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowInterval,
              onSelection: (v) => settings.slideshowInterval = v,
              tileTitle: context.l10n.settingsSlideshowIntervalTile,
            ),
            SettingsSelectionListTile<SlideshowVideoPlayback>(
              values: SlideshowVideoPlayback.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowVideoPlayback,
              onSelection: (v) => settings.slideshowVideoPlayback = v,
              tileTitle: context.l10n.settingsSlideshowVideoPlaybackTile,
              dialogTitle: context.l10n.settingsSlideshowVideoPlaybackDialogTitle,
            ),
          ],
        ),
      ),
    );
  }
}
