import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves/widgets/settings/common/switch_icon.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailOverlayPage extends StatelessWidget {
  static const routeName = '/settings/thumbnail_overlay';

  const ThumbnailOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = SettingSwitchTrailingIcon.getIconSize(context);
    final iconColor = SettingSwitchTrailingIcon.getIconColor(context);

    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(context.l10n.settingsThumbnailOverlayPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailFavourite,
              onChanged: (v) => settings.showThumbnailFavourite = v,
              title: context.l10n.settingsThumbnailShowFavouriteIcon,
              trailing: Padding(
                padding: EdgeInsets.symmetric(horizontal: iconSize * (1 - FavouriteIcon.scale) / 2),
                child: Icon(
                  AIcons.favourite,
                  size: iconSize * FavouriteIcon.scale,
                  color: iconColor,
                ),
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailMotionPhoto,
              onChanged: (v) => settings.showThumbnailMotionPhoto = v,
              title: context.l10n.settingsThumbnailShowMotionPhotoIcon,
              trailing: Padding(
                padding: EdgeInsets.symmetric(horizontal: iconSize * (1 - MotionPhotoIcon.scale) / 2),
                child: Icon(
                  AIcons.motionPhoto,
                  size: iconSize * MotionPhotoIcon.scale,
                  color: iconColor,
                ),
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailRating,
              onChanged: (v) => settings.showThumbnailRating = v,
              title: context.l10n.settingsThumbnailShowRating,
              trailing: Icon(
                AIcons.rating,
                size: iconSize,
                color: iconColor,
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailHdr,
              onChanged: (v) => settings.showThumbnailHdr = v,
              title: context.l10n.settingsThumbnailShowHdrIcon,
              trailing: Icon(
                AIcons.hdr,
                size: iconSize,
                color: iconColor,
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailRaw,
              onChanged: (v) => settings.showThumbnailRaw = v,
              title: context.l10n.settingsThumbnailShowRawIcon,
              trailing: Icon(
                AIcons.raw,
                size: iconSize,
                color: iconColor,
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailVideoDuration,
              onChanged: (v) => settings.showThumbnailVideoDuration = v,
              title: context.l10n.settingsThumbnailShowVideoDuration,
            ),
            SettingsTileThumbnailLocationIcon().build(context),
            SettingsTileThumbnailTagIcon().build(context),
          ],
        ),
      ),
    );
  }
}

class SettingsTileThumbnailLocationIcon extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThumbnailShowLocationIcon;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<ThumbnailOverlayLocationIcon>(
    values: ThumbnailOverlayLocationIcon.values,
    getName: (context, v) => v.getName(context),
    selector: (context, s) => s.thumbnailLocationIcon,
    onSelection: (v) => settings.thumbnailLocationIcon = v,
    tileTitle: title(context),
    trailingBuilder: _buildTrailing,
  );

  Widget _buildTrailing(BuildContext context) {
    final iconType = context.select<Settings, ThumbnailOverlayLocationIcon>((v) => v.thumbnailLocationIcon);
    return SettingSwitchTrailingIcon(
      key: ValueKey(iconType),
      icon: iconType.getIcon(context),
      disabled: iconType == ThumbnailOverlayLocationIcon.none,
    );
  }
}

class SettingsTileThumbnailTagIcon extends SettingsTile {
  @override
  String title(BuildContext context) => context.l10n.settingsThumbnailShowTagIcon;

  @override
  Widget build(BuildContext context) => SettingsSelectionListTile<ThumbnailOverlayTagIcon>(
    values: ThumbnailOverlayTagIcon.values,
    getName: (context, v) => v.getName(context),
    selector: (context, s) => s.thumbnailTagIcon,
    onSelection: (v) => settings.thumbnailTagIcon = v,
    tileTitle: title(context),
    trailingBuilder: _buildTrailing,
  );

  Widget _buildTrailing(BuildContext context) {
    final iconType = context.select<Settings, ThumbnailOverlayTagIcon>((v) => v.thumbnailTagIcon);
    return SettingSwitchTrailingIcon(
      key: ValueKey(iconType),
      icon: iconType.getIcon(context),
      disabled: iconType == ThumbnailOverlayTagIcon.none,
    );
  }
}
