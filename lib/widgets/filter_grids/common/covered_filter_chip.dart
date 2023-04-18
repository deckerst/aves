import 'dart:math';

import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/model/apps.dart';
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
  final FilterCallback? onTap;
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

  static double tileHeight({required double extent, required double textScaleFactor, required bool showText}) {
    return extent + infoHeight(extent: extent, textScaleFactor: textScaleFactor, showText: showText);
  }

  // info includes title and content details
  static double infoHeight({required double extent, required double textScaleFactor, required bool showText}) {
    if (!showText) return 0;

    // height can actually be a little larger or smaller, when info includes icons or non-latin scripts
    // but it's not worth measuring text metrics, as the widget is flexible enough to absorb the difference
    return (AvesFilterChip.fontSize + detailFontSize(extent) + 4) * textScaleFactor + AvesFilterChip.decoratedContentVerticalPadding * 2;
  }

  static Radius radius(double extent) => Radius.circular(min<double>(AvesFilterChip.defaultRadius, extent / 4));

  static double detailIconSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 8);

  static double detailFontSize(double extent) => min<double>(AvesFilterChip.fontSize, extent / 6);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<CollectionFilter>?>(
      stream: covers.entryChangeStream.where((event) => event == null || event.contains(filter)),
      builder: (context, snapshot) => Consumer<CollectionSource>(
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
                final countryCode = (filter as LocationFilter).code;
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
      ),
    );
  }

  Widget _buildChip(BuildContext context, CollectionSource source) {
    final _filter = filter;
    final entry = _filter is AlbumFilter && vaults.isLocked(_filter.album) ? null : source.coverEntry(_filter);
    final titlePadding = min<double>(4.0, extent / 32);
    Key? chipKey;
    if (_filter is AlbumFilter) {
      // when we asynchronously fetch installed app names,
      // album filters themselves do not change, but decoration derived from it does
      chipKey = ValueKey(appInventory.areAppNamesReadyNotifier.value);
    }
    return AvesFilterChip(
      key: chipKey,
      filter: _filter,
      showText: showText,
      showGenericIcon: false,
      decoration: AvesFilterDecoration(
        widget: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.textScaleFactor,
          builder: (context, textScaleFactor, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: infoHeight(
                  extent: extent,
                  textScaleFactor: textScaleFactor,
                  showText: showText,
                ),
              ),
              child: child,
            );
          },
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
                ),
        ),
        radius: radius(extent),
      ),
      banner: banner,
      details: showText ? _buildDetails(context, source, _filter) : null,
      padding: titlePadding,
      heroType: heroType,
      onTap: onTap,
      onLongPress: null,
    );
  }

  Color _detailColor(BuildContext context) => Theme.of(context).textTheme.bodySmall!.color!;

  Widget _buildDetails(BuildContext context, CollectionSource source, T filter) {
    final locale = context.l10n.localeName;
    final numberFormat = NumberFormat.decimalPattern(locale);

    final padding = min<double>(8.0, extent / 16);
    final iconSize = detailIconSize(extent);
    final fontSize = detailFontSize(extent);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinned)
          AnimatedPadding(
            padding: EdgeInsetsDirectional.only(end: padding),
            duration: Durations.chipDecorationAnimation,
            child: Icon(
              AIcons.pin,
              color: _detailColor(context),
              size: iconSize,
            ),
          ),
        if (filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album))
          AnimatedPadding(
            padding: EdgeInsetsDirectional.only(end: padding),
            duration: Durations.chipDecorationAnimation,
            child: Icon(
              AIcons.removableStorage,
              color: _detailColor(context),
              size: iconSize,
            ),
          ),
        if (filter is AlbumFilter && vaults.isVault(filter.album))
          AnimatedPadding(
            padding: EdgeInsetsDirectional.only(end: padding),
            duration: Durations.chipDecorationAnimation,
            child: Icon(
              AIcons.locked,
              color: _detailColor(context),
              size: iconSize,
            ),
          ),
        Text(
          locked ? AText.valueNotAvailable : numberFormat.format(source.count(filter)),
          style: TextStyle(
            color: _detailColor(context),
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
