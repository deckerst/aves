import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/thumbnail/image.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoveredFilterChip<T extends CollectionFilter> extends StatelessWidget {
  final T filter;
  final double extent, thumbnailExtent;
  final AvesEntry? coverEntry;
  final bool pinned;
  final String? banner;
  final FilterCallback? onTap;

  const CoveredFilterChip({
    Key? key,
    required this.filter,
    required this.extent,
    double? thumbnailExtent,
    this.coverEntry,
    this.pinned = false,
    this.banner,
    this.onTap,
  })  : thumbnailExtent = thumbnailExtent ?? extent,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionSource>(
      builder: (context, source, child) {
        switch (T) {
          case AlbumFilter:
            {
              final album = (filter as AlbumFilter).album;
              return StreamBuilder<AlbumSummaryInvalidatedEvent>(
                stream: source.eventBus.on<AlbumSummaryInvalidatedEvent>().where((event) => event.directories == null || event.directories!.contains(album)),
                builder: (context, snapshot) => _buildChip(source),
              );
            }
          case LocationFilter:
            {
              final countryCode = (filter as LocationFilter).countryCode;
              return StreamBuilder<CountrySummaryInvalidatedEvent>(
                stream: source.eventBus.on<CountrySummaryInvalidatedEvent>().where((event) => event.countryCodes == null || event.countryCodes!.contains(countryCode)),
                builder: (context, snapshot) => _buildChip(source),
              );
            }
          case TagFilter:
            {
              final tag = (filter as TagFilter).tag;
              return StreamBuilder<TagSummaryInvalidatedEvent>(
                stream: source.eventBus.on<TagSummaryInvalidatedEvent>().where((event) => event.tags == null || event.tags!.contains(tag)),
                builder: (context, snapshot) => _buildChip(source),
              );
            }
          default:
            return const SizedBox();
        }
      },
    );
  }

  static Radius radius(double extent) => Radius.circular(min<double>(AvesFilterChip.defaultRadius, extent / 4));

  Widget _buildChip(CollectionSource source) {
    final entry = coverEntry ?? source.coverEntry(filter);
    final backgroundImage = entry == null
        ? Container(color: Colors.white)
        : ThumbnailImage(
            entry: entry,
            extent: thumbnailExtent,
          );
    final titlePadding = min<double>(4.0, extent / 32);
    return SizedBox(
      width: extent,
      height: extent,
      child: AvesFilterChip(
        filter: filter,
        showGenericIcon: false,
        background: backgroundImage,
        banner: banner,
        details: _buildDetails(source, filter),
        borderRadius: BorderRadius.all(radius(extent)),
        padding: titlePadding,
        onTap: onTap,
        onLongPress: null,
      ),
    );
  }

  Widget _buildDetails(CollectionSource source, T filter) {
    final padding = min<double>(8.0, extent / 16);
    final iconSize = min<double>(14.0, extent / 8);
    final fontSize = min<double>(14.0, extent / 6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinned)
          AnimatedPadding(
            padding: EdgeInsets.only(right: padding),
            duration: Durations.chipDecorationAnimation,
            child: DecoratedIcon(
              AIcons.pin,
              color: FilterGridPage.detailColor,
              shadows: Constants.embossShadows,
              size: iconSize,
            ),
          ),
        if (filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album))
          AnimatedPadding(
            padding: EdgeInsets.only(right: padding),
            duration: Durations.chipDecorationAnimation,
            child: DecoratedIcon(
              AIcons.removableStorage,
              color: FilterGridPage.detailColor,
              shadows: Constants.embossShadows,
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
