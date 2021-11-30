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
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
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
  final HeroType heroType;

  const CoveredFilterChip({
    Key? key,
    required this.filter,
    required this.extent,
    double? thumbnailExtent,
    this.coverEntry,
    this.pinned = false,
    this.banner,
    this.onTap,
    this.heroType = HeroType.onTap,
  })  : thumbnailExtent = thumbnailExtent ?? extent,
        super(key: key);

  static double tileHeight({required double extent, required double textScaleFactor}) {
    return extent + infoHeight(extent: extent, textScaleFactor: textScaleFactor);
  }

  static double infoHeight({required double extent, required double textScaleFactor}) {
    // height can actually be a little larger or smaller, when info includes icons or non-latin scripts
    // but it's not worth measuring text metrics, as the widget is flexible enough to absorb the difference
    return (AvesFilterChip.fontSize + detailFontSize(extent) + 4) * textScaleFactor + AvesFilterChip.decoratedContentVerticalPadding * 2;
  }

  static Radius radius(double extent) => Radius.circular(min<double>(AvesFilterChip.defaultRadius, extent / 4));

  static double detailIconSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 8);

  static double detailFontSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 6);

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
                builder: (context, snapshot) => _buildChip(context, source),
              );
            }
          case LocationFilter:
            {
              final countryCode = (filter as LocationFilter).countryCode;
              return StreamBuilder<CountrySummaryInvalidatedEvent>(
                stream: source.eventBus.on<CountrySummaryInvalidatedEvent>().where((event) => event.countryCodes == null || event.countryCodes!.contains(countryCode)),
                builder: (context, snapshot) => _buildChip(context, source),
              );
            }
          case TagFilter:
            {
              final tag = (filter as TagFilter).tag;
              return StreamBuilder<TagSummaryInvalidatedEvent>(
                stream: source.eventBus.on<TagSummaryInvalidatedEvent>().where((event) => event.tags == null || event.tags!.contains(tag)),
                builder: (context, snapshot) => _buildChip(context, source),
              );
            }
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildChip(BuildContext context, CollectionSource source) {
    final entry = coverEntry ?? source.coverEntry(filter);
    final titlePadding = min<double>(4.0, extent / 32);
    Key? chipKey;
    if (filter is AlbumFilter) {
      // when we asynchronously fetch installed app names,
      // album filters themselves do not change, but decoration derived from it does
      chipKey = ValueKey(androidFileUtils.areAppNamesReadyNotifier.value);
    }
    return AvesFilterChip(
      key: chipKey,
      filter: filter,
      showGenericIcon: false,
      decoration: AvesFilterDecoration(
        widget: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.textScaleFactor,
          builder: (context, textScaleFactor, child) {
            return Padding(
              padding: EdgeInsets.only(bottom: infoHeight(extent: extent, textScaleFactor: textScaleFactor)),
              child: child,
            );
          },
          child: entry == null
              ? FutureBuilder<Color>(
                  future: filter.color(context),
                  builder: (context, snapshot) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            snapshot.data ?? Colors.white,
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ThumbnailImage(
                  entry: entry,
                  extent: thumbnailExtent,
                ),
        ),
        radius: radius(extent),
      ),
      banner: banner,
      details: _buildDetails(source, filter),
      padding: titlePadding,
      heroType: heroType,
      onTap: onTap,
      onLongPress: null,
    );
  }

  Widget _buildDetails(CollectionSource source, T filter) {
    final padding = min<double>(8.0, extent / 16);
    final iconSize = detailIconSize(extent);
    final fontSize = detailFontSize(extent);
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
