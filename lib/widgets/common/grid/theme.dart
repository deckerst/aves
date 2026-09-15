import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const GridTheme({
  super.key,
  required final double extent,
  final bool showLocation = true,
  final bool? showTrash,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<Settings, MediaQueryData, GridThemeData>(
      update: (context, settings, mq, previous) {
        final margin = OverlayIcon.defaultMargin.vertical;
        var iconSize = min<double>(24.0, ((extent - margin) / 5).floorToDouble() - margin);
        final fontSize = (iconSize * .7).floorToDouble();
        iconSize = mq.textScaler.scale(iconSize);
        final highlightBorderWidth = extent * .1;
        final interactiveDimension = min(iconSize * 2, kMinInteractiveDimension);
        return GridThemeData(
          iconSize: iconSize,
          fontSize: fontSize,
          highlightBorderWidth: highlightBorderWidth,
          interactiveDimension: interactiveDimension,
          useTvLayout: settings.useTvLayout,
          showFavourite: settings.showThumbnailFavourite,
          showHdr: settings.showThumbnailHdr,
          locationIcon: showLocation ? settings.thumbnailLocationIcon : ThumbnailOverlayLocationIcon.none,
          tagIcon: settings.thumbnailTagIcon,
          showMotionPhoto: settings.showThumbnailMotionPhoto,
          showRating: settings.showThumbnailRating,
          showRaw: settings.showThumbnailRaw,
          showTrash: showTrash ?? true,
          showVideoDuration: settings.showThumbnailVideoDuration,
        );
      },
      child: child,
    );
  }
}

typedef GridThemeIconBuilder = List<Widget> Function(BuildContext context, AvesEntry entry);

class GridThemeData({
  required final double iconSize,
  required final double fontSize,
  required final double highlightBorderWidth,
  required final double interactiveDimension,
  required final bool useTvLayout,
  required final bool showFavourite,
  required final bool showHdr,
  required ThumbnailOverlayLocationIcon locationIcon,
  required ThumbnailOverlayTagIcon tagIcon,
  required final bool showMotionPhoto,
  required final bool showRating,
  required final bool showRaw,
  required final bool showTrash,
  required final bool showVideoDuration,
}) {
  final showLocated = locationIcon == ThumbnailOverlayLocationIcon.located;
  final showUnlocated = locationIcon == ThumbnailOverlayLocationIcon.unlocated;
  final showTagged = tagIcon == ThumbnailOverlayTagIcon.tagged;
  final showUntagged = tagIcon == ThumbnailOverlayTagIcon.untagged;
  late final GridThemeIconBuilder iconBuilder;

  this {
    iconBuilder = (context, entry) {
      final located = entry.hasGps;
      final tagged = entry.tags.isNotEmpty;
      final isMultiPage = entry.isMultiPage;
      return [
        if (entry.isFavourite && showFavourite) const FavouriteIcon(),
        if (tagged && showTagged) TagIcon.tagged(),
        if (!tagged && showUntagged) TagIcon.untagged(),
        if (located && showLocated) LocationIcon.located(),
        if (!located && showUnlocated) LocationIcon.unlocated(),
        if (entry.rating != 0 && showRating) RatingIcon(entry: entry),
        if (entry.isHdr && showHdr) const HdrIcon(),
        if (entry.isPureVideo)
          VideoIcon(entry: entry)
        else if (entry.isAnimated)
          const AnimatedImageIcon()
        else ...[
          if ((entry.isRaw || (isMultiPage && entry.stackedEntries?.any((v) => v.isRaw) == true)) && showRaw) const RawIcon(),
          if (entry.is360) const PanoramaIcon(),
        ],
        if (entry.isMotionPhoto && showMotionPhoto) const MotionPhotoIcon(),
        if (isMultiPage && !entry.isMotionPhoto) MultiPageIcon(entry: entry),
        if (entry.isGeotiff) const GeoTiffIcon(),
        if (entry.trashed && showTrash) TrashIcon(trashDaysLeft: entry.trashDaysLeft),
      ];
    };
  }
}
