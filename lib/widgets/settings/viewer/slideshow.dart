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
        title: Text(context.l10n.settingsViewerSlideshowTitle),
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
            SettingsSelectionListTile<ViewerTransition>(
              values: ViewerTransition.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowTransition,
              onSelection: (v) => settings.slideshowTransition = v,
              tileTitle: context.l10n.settingsSlideshowTransitionTile,
              dialogTitle: context.l10n.settingsSlideshowTransitionTitle,
            ),
            SettingsSelectionListTile<SlideshowInterval>(
              values: SlideshowInterval.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowInterval,
              onSelection: (v) => settings.slideshowInterval = v,
              tileTitle: context.l10n.settingsSlideshowIntervalTile,
              dialogTitle: context.l10n.settingsSlideshowIntervalTitle,
            ),
            SettingsSelectionListTile<SlideshowVideoPlayback>(
              values: SlideshowVideoPlayback.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowVideoPlayback,
              onSelection: (v) => settings.slideshowVideoPlayback = v,
              tileTitle: context.l10n.settingsSlideshowVideoPlaybackTile,
              dialogTitle: context.l10n.settingsSlideshowVideoPlaybackTitle,
            ),
          ],
        ),
      ),
    );
  }
}
