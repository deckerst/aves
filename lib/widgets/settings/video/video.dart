import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/settings/video_loop_mode.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/video/subtitle_theme.dart';
import 'package:aves/widgets/settings/video/video_actions_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const VideoSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentShowVideos = context.select<Settings, bool>((s) => !s.hiddenFilters.contains(MimeFilter.video));
    final currentEnableVideoHardwareAcceleration = context.select<Settings, bool>((s) => s.enableVideoHardwareAcceleration);
    final currentEnableVideoAutoPlay = context.select<Settings, bool>((s) => s.enableVideoAutoPlay);
    final currentVideoLoopMode = context.select<Settings, VideoLoopMode>((s) => s.videoLoopMode);

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.video,
        color: stringToColor('Video'),
      ),
      title: context.l10n.settingsSectionVideo,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
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
      ],
    );
  }
}
