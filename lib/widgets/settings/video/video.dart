import 'dart:async';

import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/video/controls.dart';
import 'package:aves/widgets/settings/video/playback.dart';
import 'package:aves/widgets/settings/video/subtitle_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoSection extends SettingsSection {
  final bool standalonePage;

  VideoSection({
    this.standalonePage = false,
  });

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
  FutureOr<List<SettingsTile>> tiles(BuildContext context) async {
    return [
      if (!standalonePage) SettingsTileVideoShowVideos(),
      SettingsTileVideoPlayback(),
      if (!settings.useTvLayout) SettingsTileVideoControls(),
      SettingsTileVideoSubtitleTheme(),
    ];
  }
}

class SettingsTileVideoShowVideos extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoShowVideos;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => !s.hiddenFilters.contains(MimeFilter.video),
        onChanged: (v) => settings.changeFilterVisibility({MimeFilter.video}, v),
        title: title(context),
      );
}

class SettingsTileVideoPlayback extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoPlaybackTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: VideoPlaybackPage.routeName,
        builder: (context) => const VideoPlaybackPage(),
      );
}

class SettingsTileVideoControls extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoControlsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: VideoControlsPage.routeName,
        builder: (context) => const VideoControlsPage(),
      );
}

class SettingsTileVideoSubtitleTheme extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsSubtitleThemeTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: SubtitleThemePage.routeName,
        builder: (context) => const SubtitleThemePage(),
      );
}
