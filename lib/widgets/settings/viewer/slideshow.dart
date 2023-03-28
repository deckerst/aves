import 'package:aves/model/settings/enums/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class ViewerSlideshowPage extends StatelessWidget {
  static const routeName = '/settings/viewer/slideshow';

  const ViewerSlideshowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(l10n.settingsViewerSlideshowPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowRepeat,
              onChanged: (v) => settings.slideshowRepeat = v,
              title: l10n.settingsSlideshowRepeat,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowShuffle,
              onChanged: (v) => settings.slideshowShuffle = v,
              title: l10n.settingsSlideshowShuffle,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowFillScreen,
              onChanged: (v) => settings.slideshowFillScreen = v,
              title: l10n.settingsSlideshowFillScreen,
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.slideshowAnimatedZoomEffect,
              onChanged: (v) => settings.slideshowAnimatedZoomEffect = v,
              title: l10n.settingsSlideshowAnimatedZoomEffect,
            ),
            SettingsSelectionListTile<ViewerTransition>(
              values: ViewerTransition.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowTransition,
              onSelection: (v) => settings.slideshowTransition = v,
              tileTitle: l10n.settingsSlideshowTransitionTile,
            ),
            SettingsDurationListTile(
              selector: (context, s) => s.slideshowInterval,
              onChanged: (v) => settings.slideshowInterval = v,
              title: l10n.settingsSlideshowIntervalTile,
            ),
            SettingsSelectionListTile<SlideshowVideoPlayback>(
              values: SlideshowVideoPlayback.values,
              getName: (context, v) => v.getName(context),
              selector: (context, s) => s.slideshowVideoPlayback,
              onSelection: (v) => settings.slideshowVideoPlayback = v,
              tileTitle: l10n.settingsSlideshowVideoPlaybackTile,
              dialogTitle: l10n.settingsSlideshowVideoPlaybackDialogTitle,
            ),
          ],
        ),
      ),
    );
  }
}
