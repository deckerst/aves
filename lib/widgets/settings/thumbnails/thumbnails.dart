import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/thumbnails/collection_actions_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailsSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const ThumbnailsSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = IconTheme.of(context).size! * MediaQuery.textScaleFactorOf(context);
    double opacityFor(bool enabled) => enabled ? 1 : .2;

    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.grid,
        color: stringToColor('Thumbnails'),
      ),
      title: context.l10n.settingsSectionThumbnails,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        const CollectionActionsTile(),
        Selector<Settings, bool>(
          selector: (context, s) => s.showThumbnailLocation,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showThumbnailLocation = v,
            title: Row(
              children: [
                Expanded(child: Text(context.l10n.settingsThumbnailShowLocationIcon)),
                AnimatedOpacity(
                  opacity: opacityFor(current),
                  duration: Durations.toggleableTransitionAnimation,
                  child: Icon(
                    AIcons.location,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showThumbnailMotionPhoto,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showThumbnailMotionPhoto = v,
            title: Row(
              children: [
                Expanded(child: Text(context.l10n.settingsThumbnailShowMotionPhotoIcon)),
                AnimatedOpacity(
                  opacity: opacityFor(current),
                  duration: Durations.toggleableTransitionAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: iconSize * (1 - MotionPhotoIcon.scale) / 2),
                    child: Icon(
                      AIcons.motionPhoto,
                      size: iconSize * MotionPhotoIcon.scale,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showThumbnailRating,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showThumbnailRating = v,
            title: Row(
              children: [
                Expanded(child: Text(context.l10n.settingsThumbnailShowRating)),
                AnimatedOpacity(
                  opacity: opacityFor(current),
                  duration: Durations.toggleableTransitionAnimation,
                  child: Icon(
                    AIcons.rating,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showThumbnailRaw,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showThumbnailRaw = v,
            title: Row(
              children: [
                Expanded(child: Text(context.l10n.settingsThumbnailShowRawIcon)),
                AnimatedOpacity(
                  opacity: opacityFor(current),
                  duration: Durations.toggleableTransitionAnimation,
                  child: Icon(
                    AIcons.raw,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showThumbnailVideoDuration,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showThumbnailVideoDuration = v,
            title: Text(context.l10n.settingsThumbnailShowVideoDuration),
          ),
        ),
      ],
    );
  }
}
