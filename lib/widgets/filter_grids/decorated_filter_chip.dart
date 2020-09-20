import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/collection/thumbnail/vector.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';

class DecoratedFilterChip extends StatelessWidget {
  final CollectionSource source;
  final CollectionFilter filter;
  final ImageEntry entry;
  final bool pinned;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const DecoratedFilterChip({
    Key key,
    @required this.source,
    @required this.filter,
    @required this.entry,
    this.pinned = false,
    @required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget backgroundImage;
    if (entry != null) {
      backgroundImage = entry.isSvg
          ? ThumbnailVectorImage(
              entry: entry,
              extent: FilterGridPage.maxCrossAxisExtent,
            )
          : ThumbnailRasterImage(
              entry: entry,
              extent: FilterGridPage.maxCrossAxisExtent,
            );
    }
    return AvesFilterChip(
      filter: filter,
      showGenericIcon: false,
      background: backgroundImage,
      details: _buildDetails(filter),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildDetails(CollectionFilter filter) {
    final count = Text(
      '${source.count(filter)}',
      style: TextStyle(color: FilterGridPage.detailColor),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinned)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              AIcons.pin,
              size: 16,
              color: FilterGridPage.detailColor,
            ),
          ),
        if (filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album))
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              AIcons.removableStorage,
              size: 16,
              color: FilterGridPage.detailColor,
            ),
          ),
        count,
      ],
    );
  }
}
