import 'dart:async';

import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/src/settings/enums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_list_subtitle.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/reorderable_list.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles/sub_page.dart';
import 'package:aves/widgets/settings/common/tiles/switch_list.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/video/controls_page.dart';
import 'package:aves/widgets/settings/video/playback_page.dart';
import 'package:aves/widgets/settings/video/subtitle_theme_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class VideoSection({
  final bool standalonePage = false,
}) extends SettingsSection {
  @override
  String get key => 'video';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
    icon: AIcons.video,
    color: context.select<AvesColorsData, Color>((v) => v.video),
  );

  @override
  String title(BuildContext context) => context.l10n.settingsVideoSectionTitle;

  @override
  Future<List<SettingsTile>> tiles(BuildContext context) async {
    return [
      if (!standalonePage) SettingsTileVideoShowVideos(),
      SettingsTileVideoPlayback(),
      if (!settings.useTvLayout) SettingsTileVideoControls(),
      SettingsTileVideoSubtitleTheme(),
      if (!settings.useTvLayout) SettingsTileVideoThumbnailMethods(),
    ];
  }
}

class SettingsTileVideoShowVideos extends SettingsTile {
  @override
  List<String> get settingKeys => []; // prefer main hidden filter setting page

  @override
  String title(BuildContext context) => context.l10n.settingsVideoShowVideos;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => !s.hiddenFilters.contains(MimeFilter.video),
    onChanged: (v) => settings.changeFilterVisibility({MimeFilter.video}, v),
    title: title,
  );
}

class SettingsTileVideoPlayback extends SettingsTile {
  @override
  List<String> get settingKeys => VideoPlaybackPage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsVideoPlaybackTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: VideoPlaybackPage.routeName,
    builder: (context) => const VideoPlaybackPage(),
  );
}

class SettingsTileVideoControls extends SettingsTile {
  @override
  List<String> get settingKeys => VideoControlsPage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsVideoControlsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: VideoControlsPage.routeName,
    builder: (context) => const VideoControlsPage(),
  );
}

class SettingsTileVideoSubtitleTheme extends SettingsTile {
  @override
  List<String> get settingKeys => SubtitleThemePage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsSubtitleThemeTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: SubtitleThemePage.routeName,
    builder: (context) => const SubtitleThemePage(),
  );
}

class SettingsTileVideoThumbnailMethods extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.videoThumbnailMethodsKey];

  @override
  String title(BuildContext context) => context.l10n.settingsVideoThumbnailMethods;

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, List<VideoThumbnailMethod>>(
      selector: (context, s) => s.videoThumbnailMethods,
      builder: (context, current, child) {
        return ListTile(
          title: Text(title(context)),
          subtitle: AvesListSubtitle(current.map((v) => v.getName(context)).join(', ')),
          onTap: () async {
            final value = await showAvesDialog<List<VideoThumbnailMethod>>(
              context: context,
              builder: (context) {
                return AvesReorderableListDialog<VideoThumbnailMethod>(
                  initialValue: current,
                  options: Map.fromEntries(VideoThumbnailMethod.values.map((v) => MapEntry(v, v.getName(context)))),
                );
              },
              routeSettings: const RouteSettings(name: AvesReorderableListDialog.routeName),
            );
            // wait for the dialog to hide
            await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
            if (value != null) {
              settings.videoThumbnailMethods = value;
            }
          },
        );
      },
    );
  }
}
