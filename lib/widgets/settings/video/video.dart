import 'dart:async';

import 'package:aves/model/device.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/video/controls.dart';
import 'package:aves/widgets/settings/video/subtitle_theme.dart';
import 'package:aves_model/aves_model.dart';
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
      SettingsTileVideoEnableHardwareAcceleration(),
      SettingsTileVideoEnableAutoPlay(),
      SettingsTileVideoLoopMode(),
      if (!settings.useTvLayout && device.supportPictureInPicture) SettingsTileVideoBackgroundMode(),
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

class SettingsTileVideoEnableHardwareAcceleration extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoEnableHardwareAcceleration;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.enableVideoHardwareAcceleration,
        onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
        title: title(context),
      );
}

class SettingsTileVideoEnableAutoPlay extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoAutoPlay;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<VideoAutoPlayMode>(
        values: VideoAutoPlayMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.videoAutoPlayMode,
        onSelection: (v) => settings.videoAutoPlayMode = v,
        tileTitle: title(context),
      );
}

class SettingsTileVideoLoopMode extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoLoopModeTile;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<VideoLoopMode>(
        values: VideoLoopMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.videoLoopMode,
        onSelection: (v) => settings.videoLoopMode = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsVideoLoopModeDialogTitle,
      );
}

class SettingsTileVideoBackgroundMode extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsVideoBackgroundMode;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<VideoBackgroundMode>(
        values: VideoBackgroundMode.values,
        getName: (context, v) => v.getName(context),
        selector: (context, s) => s.videoBackgroundMode,
        onSelection: (v) => settings.videoBackgroundMode = v,
        tileTitle: title(context),
        dialogTitle: context.l10n.settingsVideoBackgroundModeDialogTitle,
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
