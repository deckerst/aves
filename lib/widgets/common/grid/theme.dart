import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridTheme extends StatelessWidget {
  final double extent;
  final bool showLocation;
  final bool? showTrash;
  final Widget child;

  const GridTheme({
    super.key,
    required this.extent,
    this.showLocation = true,
    this.showTrash,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<Settings, MediaQueryData, GridThemeData>(
      update: (context, settings, mq, previous) {
        final margin = OverlayIcon.defaultMargin.vertical;
        var iconSize = min(24.0, ((extent - margin) / 5).floorToDouble() - margin);
        final fontSize = (iconSize * .7).floorToDouble();
        iconSize *= mq.textScaleFactor;
        final highlightBorderWidth = extent * .1;
        final interactiveDimension = min(iconSize * 2, kMinInteractiveDimension);
        return GridThemeData(
          iconSize: iconSize,
          fontSize: fontSize,
          highlightBorderWidth: highlightBorderWidth,
          interactiveDimension: interactiveDimension,
          showFavourite: settings.showThumbnailFavourite,
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

class GridThemeData {
  final double iconSize, fontSize, highlightBorderWidth, interactiveDimension;
  final bool showFavourite, showMotionPhoto, showRating, showRaw, showTrash, showVideoDuration;
  final bool showLocated, showUnlocated, showTagged, showUntagged;
  late final GridThemeIconBuilder iconBuilder;

  GridThemeData({
    required this.iconSize,
    required this.fontSize,
    required this.highlightBorderWidth,
    required this.interactiveDimension,
    required this.showFavourite,
    required ThumbnailOverlayLocationIcon locationIcon,
    required ThumbnailOverlayTagIcon tagIcon,
    required this.showMotionPhoto,
    required this.showRating,
    required this.showRaw,
    required this.showTrash,
    required this.showVideoDuration,
  })  : showLocated = locationIcon == ThumbnailOverlayLocationIcon.located,
        showUnlocated = locationIcon == ThumbnailOverlayLocationIcon.unlocated,
        showTagged = tagIcon == ThumbnailOverlayTagIcon.tagged,
        showUntagged = tagIcon == ThumbnailOverlayTagIcon.untagged {
    iconBuilder = (context, entry) {
      final located = entry.hasGps;
      final tagged = entry.tags.isNotEmpty;
      return [
        if (entry.isFavourite && showFavourite) const FavouriteIcon(),
        if (tagged && showTagged) TagIcon.tagged(),
        if (!tagged && showUntagged) TagIcon.untagged(),
        if (located && showLocated) LocationIcon.located(),
        if (!located && showUnlocated) LocationIcon.unlocated(),
        if (entry.rating != 0 && showRating) RatingIcon(entry: entry),
        if (entry.isPureVideo)
          VideoIcon(entry: entry)
        else if (entry.isAnimated)
          const AnimatedImageIcon()
        else ...[
          if (entry.isRaw && showRaw) const RawIcon(),
          if (entry.is360) const PanoramaIcon(),
        ],
        if (entry.isMultiPage) ...[
          if (entry.isMotionPhoto && showMotionPhoto) const MotionPhotoIcon(),
          if (!entry.isMotionPhoto) MultiPageIcon(entry: entry),
        ],
        if (entry.isGeotiff) const GeoTiffIcon(),
        if (entry.trashed && showTrash) TrashIcon(trashDaysLeft: entry.trashDaysLeft),
      ];
    };
  }
}
