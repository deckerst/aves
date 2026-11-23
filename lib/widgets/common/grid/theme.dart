import 'dart:math';

import 'package:aves/locale/number.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/widgets/common/identity/icons/overlay.dart';
import 'package:aves/widgets/common/identity/icons/textful.dart';
import 'package:aves/widgets/common/identity/icons/textless.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const GridTheme({
  super.key,
  required final double extent,
  final bool isCalendar = false,
  final bool showLocation = true,
  final bool? showTrash,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<Settings, MediaQueryData, GridThemeData>(
      update: (context, settings, mq, previous) {
        final margin = OverlayIcon.defaultMargin.vertical;
        final unscaledIconSize = _getUnscaledIconSize(extent, margin);
        final fontSize = getFontSize(unscaledIconSize);
        final iconSize = mq.textScaler.scale(unscaledIconSize);
        final highlightBorderWidth = extent * .1;
        final interactiveDimension = min(iconSize * 2, kMinInteractiveDimension);
        final numberFormatter = settings.avesLocale.decimalNumberFormat();
        return GridThemeData(
          iconSize: iconSize,
          fontSize: fontSize,
          numberFormatter: numberFormatter,
          highlightBorderWidth: highlightBorderWidth,
          interactiveDimension: interactiveDimension,
          useTvLayout: settings.useTvLayout,
          isCalendar: isCalendar,
          showFavourite: settings.showThumbnailFavourite,
          showHdr: settings.showThumbnailHdr,
          locationIcon: showLocation ? settings.thumbnailLocationIcon : .none,
          tagIcon: settings.thumbnailTagIcon,
          credentialValidityLevels: settings.thumbnailCredentialValidity,
          showFormat: settings.showThumbnailFormat,
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

  static double _getUnscaledIconSize(double extent, double margin) {
    return min<double>(24.0, ((extent - margin) / 5).floorToDouble() - margin);
  }

  static double getFontSize(double unscaledIconSize) => (unscaledIconSize * .7).floorToDouble();
}

typedef GridThemeIconBuilder = List<Widget> Function(BuildContext context, AvesEntry entry);

class GridThemeData({
  required final double iconSize,
  required final double fontSize,
  required final ANumberFormat numberFormatter,
  required final double highlightBorderWidth,
  required final double interactiveDimension,
  required final bool useTvLayout,
  required final bool isCalendar,
  required final bool showFavourite,
  required final bool showHdr,
  required ThumbnailOverlayLocationIcon locationIcon,
  required ThumbnailOverlayTagIcon tagIcon,
  required final Set<C2paValidity> credentialValidityLevels,
  required final bool showFormat,
  required final bool showMotionPhoto,
  required final bool showRating,
  required final bool showRaw,
  required final bool showTrash,
  required final bool showVideoDuration,
}) {
  final showLocated = locationIcon == .located;
  final showUnlocated = locationIcon == .unlocated;
  final showTagged = tagIcon == .tagged;
  final showUntagged = tagIcon == .untagged;
  late final GridThemeIconBuilder iconBuilder;

  this {
    iconBuilder = isCalendar ? _calendarIconBuilder : _defaultIconBuilder;
  }

  List<Widget> _calendarIconBuilder(BuildContext context, AvesEntry entry) {
    return [
      if (entry.isStack) CalendarStackCount(entry: entry),
    ];
  }

  List<Widget> _defaultIconBuilder(BuildContext context, AvesEntry entry) {
    final located = entry.hasGps;
    final tagged = entry.tags.isNotEmpty;
    final c2paValidity = entry.c2paValidity;
    return [
      if (credentialValidityLevels.contains(c2paValidity)) CredentialValidityIcon(validity: c2paValidity),
      if (showFavourite && entry.isFavourite) const FavouriteIcon(),
      if (showTagged && tagged) TagIcon.tagged(),
      if (showUntagged && !tagged) TagIcon.untagged(),
      if (showLocated && located) LocationIcon.located(),
      if (showUnlocated && !located) LocationIcon.unlocated(),
      if (showRating && entry.rating != 0) RatingIcon(rating: entry.rating),
      if (entry.isGeotiff) const GeoTiffIcon(),
      if (showHdr && entry.isHdr) const HdrIcon(),
      if (entry.isPureVideo)
        VideoIcon(
          entry: entry,
          showDuration: showVideoDuration,
        )
      else if (entry.isAnimated)
        const AnimatedImageIcon()
      else ...[
        if (showRaw && (entry.isRaw || (entry.stackedEntries?.any((v) => v.isRaw) == true))) const RawIcon(),
        if (entry.is360) const PanoramaIcon(),
      ],
      if (showMotionPhoto && entry.isMotionPhoto) const MotionPhotoIcon(),
      if (entry.isStack) StackIcon(entry: entry),
      if (showFormat) MimeIcon(mimeType: entry.mimeType),
      if (showTrash && entry.trashed) TrashIcon(trashDaysLeft: entry.trashDaysLeft),
    ];
  }
}
