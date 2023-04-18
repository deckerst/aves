import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/viewer/entry_background.dart';
import 'package:aves/widgets/settings/viewer/overlay.dart';
import 'package:aves/widgets/settings/viewer/slideshow.dart';
import 'package:aves/widgets/settings/viewer/viewer_actions_editor.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerSection extends SettingsSection {
  @override
  String get key => 'viewer';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.image,
        color: context.select<AvesColorsData, Color>((v) => v.image),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsViewerSectionTitle;

  @override
  FutureOr<List<SettingsTile>> tiles(BuildContext context) async {
    final isCutoutAware = await windowService.isCutoutAware();
    return [
      if (!settings.useTvLayout) SettingsTileViewerQuickActions(),
      SettingsTileViewerOverlay(),
      SettingsTileViewerSlideshow(),
      if (!settings.useTvLayout) SettingsTileViewerGestureSideTapNext(),
      if (!settings.useTvLayout && isCutoutAware) SettingsTileViewerUseCutout(),
      if (!settings.useTvLayout) SettingsTileViewerMaxBrightness(),
      SettingsTileViewerMotionPhotoAutoPlay(),
      SettingsTileViewerImageBackground(),
    ];
  }
}

class SettingsTileViewerQuickActions extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerQuickActionsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: ViewerActionEditorPage.routeName,
        builder: (context) => const ViewerActionEditorPage(),
      );
}

class SettingsTileViewerOverlay extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerOverlayTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: ViewerOverlayPage.routeName,
        builder: (context) => const ViewerOverlayPage(),
      );
}

class SettingsTileViewerSlideshow extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerSlideshowTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: ViewerSlideshowPage.routeName,
        builder: (context) => const ViewerSlideshowPage(),
      );
}

class SettingsTileViewerGestureSideTapNext extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerGestureSideTapNext;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.viewerGestureSideTapNext,
        onChanged: (v) => settings.viewerGestureSideTapNext = v,
        title: title(context),
      );
}

class SettingsTileViewerUseCutout extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerUseCutout;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.viewerUseCutout,
        onChanged: (v) => settings.viewerUseCutout = v,
        title: title(context),
      );
}

class SettingsTileViewerMaxBrightness extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsViewerMaximumBrightness;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.viewerMaxBrightness,
        onChanged: (v) => settings.viewerMaxBrightness = v,
        title: title(context),
      );
}

class SettingsTileViewerMotionPhotoAutoPlay extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsMotionPhotoAutoPlay;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
        selector: (context, s) => s.enableMotionPhotoAutoPlay,
        onChanged: (v) => settings.enableMotionPhotoAutoPlay = v,
        title: title(context),
      );
}

class SettingsTileViewerImageBackground extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsImageBackground;

  @override
  Widget build(BuildContext context) => Selector<Settings, EntryBackground>(
        selector: (context, s) => s.imageBackground,
        builder: (context, current, child) => ListTile(
          title: Text(title(context)),
          trailing: EntryBackgroundSelector(
            getter: () => current,
            setter: (value) => settings.imageBackground = value,
          ),
        ),
      );
}
