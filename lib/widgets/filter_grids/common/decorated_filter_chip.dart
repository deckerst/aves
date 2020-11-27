import 'dart:math';
import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/collection/thumbnail/vector.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/common/overlay.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class DecoratedFilterChip extends StatelessWidget {
  final CollectionSource source;
  final CollectionFilter filter;
  final ImageEntry entry;
  final double extent;
  final bool pinned, highlightable;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const DecoratedFilterChip({
    Key key,
    @required this.source,
    @required this.filter,
    @required this.entry,
    @required this.extent,
    this.pinned = false,
    this.highlightable = true,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundImage = entry == null
        ? Container(color: Colors.white)
        : entry.isSvg
            ? ThumbnailVectorImage(
                entry: entry,
                extent: extent,
              )
            : ThumbnailRasterImage(
                entry: entry,
                extent: extent,
              );
    final radius = min<double>(AvesFilterChip.defaultRadius, extent / 4);
    final titlePadding = min<double>(6.0, extent / 16);
    final borderRadius = BorderRadius.all(Radius.circular(radius));
    Widget child = AvesFilterChip(
      filter: filter,
      showGenericIcon: false,
      background: backgroundImage,
      details: _buildDetails(filter),
      borderRadius: borderRadius,
      padding: titlePadding,
      onTap: onTap,
      onLongPress: onLongPress,
    );

    child = Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        if (highlightable)
          ChipHighlightOverlay(
            filter: filter,
            extent: extent,
            borderRadius: borderRadius,
          ),
      ],
    );

    return child;
  }

  Widget _buildDetails(CollectionFilter filter) {
    final padding = min<double>(8.0, extent / 16);
    final iconSize = min<double>(14.0, extent / 8);
    final fontSize = min<double>(14.0, extent / 6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinned)
          AnimatedPadding(
            padding: EdgeInsets.only(right: padding),
            child: DecoratedIcon(
              AIcons.pin,
              color: FilterGridPage.detailColor,
              shadows: [Constants.embossShadow],
              size: iconSize,
            ),
            duration: Durations.chipDecorationAnimation,
          ),
        if (filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album))
          AnimatedPadding(
            padding: EdgeInsets.only(right: padding),
            duration: Durations.chipDecorationAnimation,
            child: DecoratedIcon(
              AIcons.removableStorage,
              color: FilterGridPage.detailColor,
              shadows: [Constants.embossShadow],
              size: iconSize,
            ),
          ),
        Text(
          '${source.count(filter)}',
          style: TextStyle(
            color: FilterGridPage.detailColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
