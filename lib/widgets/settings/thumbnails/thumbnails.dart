import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/thumbnails/collection_actions_editor.dart';
import 'package:aves/widgets/settings/thumbnails/overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailsSection extends SettingsSection {
  @override
  String get key => 'thumbnails';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
        icon: AIcons.grid,
        color: context.select<AvesColorsData, Color>((v) => v.thumbnails),
      );

  @override
  String title(BuildContext context) => context.l10n.settingsSectionThumbnails;

  @override
  List<SettingsTile> tiles(BuildContext context) => [
        SettingsTileCollectionQuickActions(),
        SettingsTileThumbnailOverlay(),
      ];
}

class SettingsTileCollectionQuickActions extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsCollectionQuickActionsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: CollectionActionEditorPage.routeName,
        builder: (context) => const CollectionActionEditorPage(),
      );
}

class SettingsTileThumbnailOverlay extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThumbnailOverlayTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
        title: title(context),
        routeName: ThumbnailOverlayPage.routeName,
        builder: (context) => const ThumbnailOverlayPage(),
      );
}
