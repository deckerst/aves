import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/video_loop_mode.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
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
        Selector<Settings, bool>(
          selector: (context, s) => !s.hiddenFilters.contains(MimeFilter.video),
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.changeFilterVisibility({MimeFilter.video}, v),
            title: Text(context.l10n.settingsVideoShowVideos),
          ),
        ),
      Selector<Settings, bool>(
        selector: (context, s) => s.enableVideoHardwareAcceleration,
        builder: (context, current, child) => SwitchListTile(
          value: current,
          onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
          title: Text(context.l10n.settingsVideoEnableHardwareAcceleration),
        ),
      ),
      Selector<Settings, bool>(
        selector: (context, s) => s.enableVideoAutoPlay,
        builder: (context, current, child) => SwitchListTile(
          value: current,
          onChanged: (v) => settings.enableVideoAutoPlay = v,
          title: Text(context.l10n.settingsVideoEnableAutoPlay),
        ),
      ),
      Selector<Settings, VideoLoopMode>(
        selector: (context, s) => s.videoLoopMode,
        builder: (context, current, child) => ListTile(
          title: Text(context.l10n.settingsVideoLoopModeTile),
          subtitle: Text(current.getName(context)),
          onTap: () => showSelectionDialog<VideoLoopMode>(
            context: context,
            builder: (context) => AvesSelectionDialog<VideoLoopMode>(
              initialValue: current,
              options: Map.fromEntries(VideoLoopMode.values.map((v) => MapEntry(v, v.getName(context)))),
              title: context.l10n.settingsVideoLoopModeTitle,
            ),
            onSelection: (v) => settings.videoLoopMode = v,
          ),
        ),
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
              color: AColors.video,
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
