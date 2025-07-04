import 'dart:math';

import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CoveredFilterChip<T extends CollectionFilter> extends StatelessWidget {
  final T filter;
  final double extent, thumbnailExtent;
  final bool showText, pinned, locked;
  final String? banner;
  final AFilterCallback? onTap;
  final HeroType heroType;

  const CoveredFilterChip({
    super.key,
    required this.filter,
    required this.extent,
    double? thumbnailExtent,
    this.showText = true,
    this.pinned = false,
    required this.locked,
    this.banner,
    this.onTap,
    this.heroType = HeroType.onTap,
  }) : thumbnailExtent = thumbnailExtent ?? extent;

  static double tileHeight({required double extent, required TextScaler textScaler, required bool showText}) {
    return extent + infoHeight(extent: extent, textScaler: textScaler, showText: showText);
  }

  // info includes title and content details
  static double infoHeight({required double extent, required TextScaler textScaler, required bool showText}) {
    if (!showText) return 0;

    // height can actually be a little larger or smaller, when info includes icons or non-latin scripts
    // but it's not worth measuring text metrics, as the widget is flexible enough to absorb the difference
    return textScaler.scale(AvesFilterChip.fontSize + detailFontSize(extent) + 4) + AvesFilterChip.decoratedContentVerticalPadding * 2;
  }

  static Radius radius(double extent) => Radius.circular(min<double>(AvesFilterChip.defaultRadius, extent / 4));

  static double detailIconSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 7);

  static double detailFontSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 7);

  static double detailIconPadding(double extent) => min<double>(8.0, extent / 16);

  static double detailIconTextPadding(double extent) => detailIconPadding(extent) / 2;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<CollectionFilter>?>(
      stream: covers.entryChangeStream.where((event) => event == null || event.contains(filter)),
      builder: (context, snapshot) => Consumer<CollectionSource>(
        builder: (context, source, child) {
          switch (filter) {
            case StoredAlbumFilter filter:
              {
                final album = filter.album;
                return StreamBuilder<StoredAlbumSummaryInvalidatedEvent>(
                  stream: source.eventBus.on<StoredAlbumSummaryInvalidatedEvent>().where((event) => event.directories == null || event.directories!.contains(album)),
                  builder: (context, snapshot) => _buildChip(context, source),
                );
              }
            case DynamicAlbumFilter _:
              {
                return StreamBuilder<DynamicAlbumSummaryInvalidatedEvent>(
                  stream: source.eventBus.on<DynamicAlbumSummaryInvalidatedEvent>(),
                  builder: (context, snapshot) => _buildChip(context, source),
                );
              }
            case AlbumGroupFilter _:
              {
                return StreamBuilder<AlbumGroupSummaryInvalidatedEvent>(
                  stream: source.eventBus.on<AlbumGroupSummaryInvalidatedEvent>(),
                  builder: (context, snapshot) => _buildChip(context, source),
                );
              }
            case LocationFilter filter:
              {
                final countryCode = filter.code;
                return StreamBuilder<CountrySummaryInvalidatedEvent>(
                  stream: source.eventBus.on<CountrySummaryInvalidatedEvent>().where((event) => event.countryCodes == null || event.countryCodes!.contains(countryCode)),
                  builder: (context, snapshot) => _buildChip(context, source),
                );
              }
            case TagFilter filter:
              {
                final tag = filter.tag;
                return StreamBuilder<TagSummaryInvalidatedEvent>(
                  stream: source.eventBus.on<TagSummaryInvalidatedEvent>().where((event) => event.tags == null || event.tags!.contains(tag)),
                  builder: (context, snapshot) => _buildChip(context, source),
                );
              }
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildChip(BuildContext context, CollectionSource source) {
    final _filter = filter;
    final entry = _filter is StoredAlbumFilter && vaults.isLocked(_filter.album) ? null : source.coverEntry(_filter);
    final titlePadding = min<double>(4.0, extent / 32);
    Key? chipKey;
    if (_filter is StoredAlbumFilter) {
      // when we asynchronously fetch installed app names,
      // album filters themselves do not change, but decoration derived from it does
      chipKey = ValueKey(appInventory.areAppNamesReadyNotifier.value);
    }
    final textScaler = MediaQuery.textScalerOf(context);
    return AvesFilterChip(
      key: chipKey,
      filter: _filter,
      showLeading: showText,
      showText: showText,
      allowGenericIcon: false,
      decoration: AvesFilterDecoration(
        radius: radius(extent),
        widget: Padding(
          padding: EdgeInsets.only(
            bottom: infoHeight(
              extent: extent,
              textScaler: textScaler,
              showText: showText,
            ),
          ),
          child: entry == null
              ? StreamBuilder<Set<CollectionFilter>?>(
                  stream: covers.colorChangeStream.where((event) => event == null || event.contains(_filter)),
                  builder: (context, snapshot) {
                    return FutureBuilder<Color>(
                      future: _filter.color(context),
                      builder: (context, snapshot) {
                        final color = snapshot.data;
                        const neutral = Colors.white;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                neutral,
                                color ?? neutral,
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : ThumbnailImage(
                  entry: entry,
                  extent: thumbnailExtent,
                  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                ),
        ),
      ),
      banner: banner,
      details: showText ? _buildDetails(context, source, _filter) : null,
      padding: titlePadding,
      heroType: heroType,
      onTap: onTap,
      onLongPress: null,
    );
  }

  Color _detailColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;

  Widget _buildDetails(BuildContext context, CollectionSource source, T filter) {
    final textStyle = TextStyle(
      color: _detailColor(context),
      fontSize: detailFontSize(extent),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinned) _buildDetailIcon(context, AIcons.pin),
        if (filter is StoredAlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album)) _buildDetailIcon(context, AIcons.storageCard),
        if (filter is StoredAlbumFilter && vaults.isVault(filter.album)) _buildDetailIcon(context, AIcons.locked),
        if (filter is DynamicAlbumFilter) _buildDetailIcon(context, AIcons.dynamicAlbum),
        if (filter is AlbumGroupFilter) ...[
          _buildDetailIcon(context, AIcons.album, padding: detailIconTextPadding(extent)),
          Text(
            '${NumberFormat.decimalPattern(context.locale).format(albumGrouping.countLeaves(filter.uri))}${AText.separator}',
            style: textStyle,
          ),
        ],
        Flexible(
          child: Text(
            locked ? AText.valueNotAvailable : NumberFormat.decimalPattern(context.locale).format(source.count(filter)),
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailIcon(BuildContext context, IconData icon, {double? padding}) {
    return AnimatedPadding(
      padding: EdgeInsetsDirectional.only(end: padding ?? detailIconPadding(extent)),
      duration: ADurations.chipDecorationAnimation,
      child: Icon(
        icon,
        color: _detailColor(context),
        size: detailIconSize(extent),
      ),
    );
  }
}
