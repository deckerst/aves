import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailOverlayPage extends StatelessWidget {
  static const routeName = '/settings/thumbnail_overlay';

  const ThumbnailOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = IconTheme.of(context).size! * MediaQuery.textScaleFactorOf(context);
    final iconColor = context.select<AvesColorsData, Color>((v) => v.neutral);

    return Scaffold(
      appBar: AppBar(
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
              selector: (context, s) => s.showThumbnailTag,
              onChanged: (v) => settings.showThumbnailTag = v,
              title: context.l10n.settingsThumbnailShowTagIcon,
              trailing: Padding(
                padding: EdgeInsets.symmetric(horizontal: iconSize * (1 - TagIcon.scale) / 2),
                child: Icon(
                  AIcons.tag,
                  size: iconSize * TagIcon.scale,
                  color: iconColor,
                ),
              ),
            ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showThumbnailLocation,
              onChanged: (v) => settings.showThumbnailLocation = v,
              title: context.l10n.settingsThumbnailShowLocationIcon,
              trailing: Icon(
                AIcons.location,
                size: iconSize,
                color: iconColor,
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
          ],
        ),
      ),
    );
  }
}
