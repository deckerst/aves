import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/bursts.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/thumbnails/collection_actions_editor_page.dart';
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
  String title(BuildContext context) => context.l10n.settingsThumbnailSectionTitle;

  @override
  List<SettingsTile> tiles(BuildContext context) => [
        if (!settings.useTvLayout) SettingsTileCollectionQuickActions(),
        SettingsTileThumbnailOverlay(),
        SettingsTileBurstPatterns(),
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

class SettingsTileBurstPatterns extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsCollectionBurstPatternsTile;

  @override
  Widget build(BuildContext context) => SettingsMultiSelectionListTile<String>(
        values: BurstPatterns.options,
        getName: (context, v) => BurstPatterns.getName(v),
        selector: (context, s) => s.collectionBurstPatterns,
        onSelection: (v) => settings.collectionBurstPatterns = v,
        tileTitle: title(context),
        noneSubtitle: context.l10n.settingsCollectionBurstPatternsNone,
        optionSubtitleBuilder: BurstPatterns.getExample,
      );
}
