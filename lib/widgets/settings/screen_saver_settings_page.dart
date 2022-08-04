import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/slideshow_interval.dart';
import 'package:aves/model/settings/enums/slideshow_video_playback.dart';
import 'package:aves/model/settings/enums/viewer_transition.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/common/collection_tile.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenSaverSettingsPage extends StatelessWidget {
  static const routeName = '/settings/screen_saver';

  const ScreenSaverSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsScreenSaverPageTitle),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              SettingsSwitchListTile(
                selector: (context, s) => s.screenSaverFillScreen,
                onChanged: (v) => settings.screenSaverFillScreen = v,
                title: context.l10n.settingsSlideshowFillScreen,
              ),
              SettingsSelectionListTile<ViewerTransition>(
                values: ViewerTransition.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.screenSaverTransition,
                onSelection: (v) => settings.screenSaverTransition = v,
                tileTitle: l10n.settingsSlideshowTransitionTile,
                dialogTitle: l10n.settingsSlideshowTransitionTitle,
              ),
              SettingsSelectionListTile<SlideshowInterval>(
                values: SlideshowInterval.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.screenSaverInterval,
                onSelection: (v) => settings.screenSaverInterval = v,
                tileTitle: l10n.settingsSlideshowIntervalTile,
                dialogTitle: l10n.settingsSlideshowIntervalTitle,
              ),
              SettingsSelectionListTile<SlideshowVideoPlayback>(
                values: SlideshowVideoPlayback.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.screenSaverVideoPlayback,
                onSelection: (v) => settings.screenSaverVideoPlayback = v,
                tileTitle: l10n.settingsSlideshowVideoPlaybackTile,
                dialogTitle: l10n.settingsSlideshowVideoPlaybackTitle,
              ),
              Selector<Settings, Set<CollectionFilter>>(
                selector: (context, s) => s.screenSaverCollectionFilters,
                builder: (context, filters, child) {
                  return SettingsCollectionTile(
                    filters: filters,
                    onSelection: (v) => settings.screenSaverCollectionFilters = v,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
