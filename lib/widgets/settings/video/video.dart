import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/video_loop_mode.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/video/controls.dart';
import 'package:aves/widgets/settings/video/subtitle_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoSection extends StatelessWidget {
  final ValueNotifier<String?>? expandedNotifier;
  final bool standalonePage;

  const VideoSection({
    Key? key,
    this.expandedNotifier,
    this.standalonePage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      if (!standalonePage)
        SettingsSwitchListTile(
          selector: (context, s) => !s.hiddenFilters.contains(MimeFilter.video),
          onChanged: (v) => settings.changeFilterVisibility({MimeFilter.video}, v),
          title: context.l10n.settingsVideoShowVideos,
        ),
      SettingsSwitchListTile(
        selector: (context, s) => s.enableVideoHardwareAcceleration,
        onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
        title: context.l10n.settingsVideoEnableHardwareAcceleration,
      ),
      SettingsSwitchListTile(
        selector: (context, s) => s.enableVideoAutoPlay,
        onChanged: (v) => settings.enableVideoAutoPlay = v,
        title: context.l10n.settingsVideoEnableAutoPlay,
      ),
      SettingsSelectionListTile<VideoLoopMode>(
        values: VideoLoopMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.videoLoopMode,
        onSelection: (v) => settings.videoLoopMode = v,
        tileTitle: context.l10n.settingsVideoLoopModeTile,
        dialogTitle: context.l10n.settingsVideoLoopModeTitle,
      ),
      const VideoControlsTile(),
      const SubtitleThemeTile(),
    ];

    return standalonePage
        ? ListView(
            children: children,
          )
        : AvesExpansionTile(
            leading: SettingsTileLeading(
              icon: AIcons.video,
              color: context.select<AvesColorsData, Color>((v) => v.video),
            ),
            title: context.l10n.settingsSectionVideo,
            expandedNotifier: expandedNotifier,
            showHighlight: false,
            children: children,
          );
  }
}

class VideoSettingsPage extends StatelessWidget {
  static const routeName = '/settings/video';

  const VideoSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsVideoPageTitle),
        ),
        body: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              // dense style font for tile subtitles, without modifying title font
              bodyText2: const TextStyle(fontSize: 12),
            ),
          ),
          child: const SafeArea(
            child: VideoSection(
              standalonePage: true,
            ),
          ),
        ),
      ),
    );
  }
}
