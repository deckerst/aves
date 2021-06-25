import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/settings/video_loop_mode.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/video/subtitle_theme.dart';
import 'package:aves/widgets/settings/video/video_actions_editor.dart';
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
    final currentShowVideos = context.select<Settings, bool>((s) => !s.hiddenFilters.contains(MimeFilter.video));
    final currentEnableVideoHardwareAcceleration = context.select<Settings, bool>((s) => s.enableVideoHardwareAcceleration);
    final currentEnableVideoAutoPlay = context.select<Settings, bool>((s) => s.enableVideoAutoPlay);
    final currentVideoLoopMode = context.select<Settings, VideoLoopMode>((s) => s.videoLoopMode);

    final children = [
      if (!standalonePage)
        SwitchListTile(
          value: currentShowVideos,
          onChanged: (v) => context.read<CollectionSource>().changeFilterVisibility(MimeFilter.video, v),
          title: Text(context.l10n.settingsVideoShowVideos),
        ),
      VideoActionsTile(),
      SwitchListTile(
        value: currentEnableVideoHardwareAcceleration,
        onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
        title: Text(context.l10n.settingsVideoEnableHardwareAcceleration),
      ),
      SwitchListTile(
        value: currentEnableVideoAutoPlay,
        onChanged: (v) => settings.enableVideoAutoPlay = v,
        title: Text(context.l10n.settingsVideoEnableAutoPlay),
      ),
      ListTile(
        title: Text(context.l10n.settingsVideoLoopModeTile),
        subtitle: Text(currentVideoLoopMode.getName(context)),
        onTap: () async {
          final value = await showDialog<VideoLoopMode>(
            context: context,
            builder: (context) => AvesSelectionDialog<VideoLoopMode>(
              initialValue: currentVideoLoopMode,
              options: Map.fromEntries(VideoLoopMode.values.map((v) => MapEntry(v, v.getName(context)))),
              title: context.l10n.settingsVideoLoopModeTitle,
            ),
          );
          if (value != null) {
            settings.videoLoopMode = value;
          }
        },
      ),
      SubtitleThemeTile(),
    ];

    return standalonePage
        ? ListView(
            children: children,
          )
        : AvesExpansionTile(
            leading: SettingsTileLeading(
              icon: AIcons.video,
              color: stringToColor('Video'),
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
