import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/stats/filter_table.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {
  static const routeName = '/collection/stats';

  final CollectionSource source;
  final CollectionLens? parentCollection;
  final Set<AvesEntry> entries;
  final Map<String, int> entryCountPerCountry = {}, entryCountPerPlace = {}, entryCountPerTag = {};
  final Map<int, int> entryCountPerRating = Map.fromEntries(List.generate(7, (i) => MapEntry(5 - i, 0)));

  static const mimeDonutMinWidth = 124.0;

  StatsPage({
    Key? key,
    required this.entries,
    required this.source,
    this.parentCollection,
  }) : super(key: key) {
    entries.forEach((entry) {
      if (entry.hasAddress) {
        final address = entry.addressDetails!;
        var country = address.countryName;
        if (country != null && country.isNotEmpty) {
          country += '${LocationFilter.locationSeparator}${address.countryCode}';
          entryCountPerCountry[country] = (entryCountPerCountry[country] ?? 0) + 1;
        }
        final place = address.place;
        if (place != null && place.isNotEmpty) {
          entryCountPerPlace[place] = (entryCountPerPlace[place] ?? 0) + 1;
        }
      }

      entry.tags.forEach((tag) {
        entryCountPerTag[tag] = (entryCountPerTag[tag] ?? 0) + 1;
      });

      final rating = entry.rating;
      entryCountPerRating[rating] = (entryCountPerRating[rating] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (entries.isEmpty) {
      child = EmptyContent(
        icon: AIcons.image,
        text: context.l10n.collectionEmptyImages,
      );
    } else {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
      final byMimeTypes = groupBy<AvesEntry, String>(entries, (entry) => entry.mimeType).map<String, int>((k, v) => MapEntry(k, v.length));
      final imagesByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('image')));
      final videoByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('video')));
      final mimeDonuts = Provider.value(
        value: isDark ? NeonOnDark() : PastelOnLight(),
        child: Builder(
          builder: (context) {
            return Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildMimeDonut(context, AIcons.image, imagesByMimeTypes, animate),
                _buildMimeDonut(context, AIcons.video, videoByMimeTypes, animate),
              ],
            );
          },
        ),
      );

      final catalogued = entries.where((entry) => entry.isCatalogued);
      final withGps = catalogued.where((entry) => entry.hasGps);
      final withGpsCount = withGps.length;
      final withGpsPercent = withGpsCount / entries.length;
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final lineHeight = 16 * textScaleFactor;
      final barRadius = Radius.circular(lineHeight / 2);
      final locationIndicator = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AIcons.location),
                Expanded(
                  child: LinearPercentIndicator(
                    percent: withGpsPercent,
                    lineHeight: lineHeight,
                    backgroundColor: theme.colorScheme.onPrimary.withOpacity(.1),
                    progressColor: theme.colorScheme.secondary,
                    animation: animate,
                    isRTL: context.isRtl,
                    barRadius: barRadius,
                    center: Text(
                      intl.NumberFormat.percentPattern().format(withGpsPercent),
                      style: TextStyle(
                        shadows: isDark ? Constants.embossShadows : null,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: lineHeight),
                  ),
                ),
                // end padding to match leading, so that inside label is aligned with outside label below
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.statsWithGps(withGpsCount),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      final showRatings = entryCountPerRating.entries.any((kv) => kv.key != 0 && kv.value > 0);
      child = ListView(
        children: [
          mimeDonuts,
          locationIndicator,
          ..._buildFilterSection<String>(context, context.l10n.statsTopCountries, entryCountPerCountry, (v) => LocationFilter(LocationLevel.country, v)),
          ..._buildFilterSection<String>(context, context.l10n.statsTopPlaces, entryCountPerPlace, (v) => LocationFilter(LocationLevel.place, v)),
          ..._buildFilterSection<String>(context, context.l10n.statsTopTags, entryCountPerTag, TagFilter.new),
          if (showRatings) ..._buildFilterSection<int>(context, context.l10n.searchSectionRating, entryCountPerRating, RatingFilter.new, sortByCount: false, maxRowCount: null),
        ],
      );
    }
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.statsPageTitle),
        ),
        body: GestureAreaProtectorStack(
          child: SafeArea(
            bottom: false,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildMimeDonut(
    BuildContext context,
    IconData icon,
    Map<String, int> byMimeTypes,
    bool animate,
  ) {
    if (byMimeTypes.isEmpty) return const SizedBox.shrink();

    final sum = byMimeTypes.values.fold<int>(0, (prev, v) => prev + v);

    final colors = context.watch<AvesColorsData>();
    final seriesData = byMimeTypes.entries.map((kv) {
      final mimeType = kv.key;
      final displayText = MimeUtils.displayType(mimeType);
      return EntryByMimeDatum(
        mimeType: mimeType,
        displayText: displayText,
        color: colors.fromString(displayText),
        entryCount: kv.value,
      );
    }).toList();
    seriesData.sort((d1, d2) {
      final c = d2.entryCount.compareTo(d1.entryCount);
      return c != 0 ? c : compareAsciiUpperCase(d1.displayText, d2.displayText);
    });

    final series = [
      charts.Series<EntryByMimeDatum, String>(
        id: 'mime',
        colorFn: (d, i) => charts.ColorUtil.fromDartColor(d.color),
        domainFn: (d, i) => d.displayText,
        measureFn: (d, i) => d.entryCount,
        data: seriesData,
        labelAccessorFn: (d, _) => '${d.displayText}: ${d.entryCount}',
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final minWidth = mimeDonutMinWidth * textScaleFactor;
      final availableWidth = constraints.maxWidth;
      final dim = max(minWidth, availableWidth / (availableWidth > 4 * minWidth ? 4 : (availableWidth > 2 * minWidth ? 2 : 1)));

      final donut = SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          children: [
            charts.PieChart(
              series,
              animate: animate,
              defaultRenderer: charts.ArcRendererConfig<String>(
                arcWidth: 16,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon),
                  Text(
                    '$sum',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      final legend = SizedBox(
        width: dim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: seriesData
              .map((d) => GestureDetector(
                    onTap: () => _onFilterSelection(context, MimeFilter(d.mimeType)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AIcons.disc, color: d.color),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            d.displayText,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${d.entryCount}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.caption!.color,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
      final children = [
        donut,
        legend,
      ];
      return availableWidth > minWidth * 2
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
    });
  }

  List<Widget> _buildFilterSection<T extends Comparable>(
    BuildContext context,
    String title,
    Map<T, int> entryCountMap,
    CollectionFilter Function(T key) filterBuilder, {
    bool sortByCount = true,
    int? maxRowCount = 5,
  }) {
    if (entryCountMap.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: Constants.titleTextStyle,
        ),
      ),
      FilterTable(
        totalEntryCount: entries.length,
        entryCountMap: entryCountMap,
        filterBuilder: filterBuilder,
        sortByCount: sortByCount,
        maxRowCount: maxRowCount,
        onFilterSelection: (filter) => _onFilterSelection(context, filter),
      ),
    ];
  }

  void _onFilterSelection(BuildContext context, CollectionFilter filter) {
    if (parentCollection != null) {
      _applyToParentCollectionPage(context, filter);
    } else {
      _jumpToCollectionPage(context, filter);
    }
  }

  void _applyToParentCollectionPage(BuildContext context, CollectionFilter filter) {
    parentCollection!.addFilter(filter);
    // we post closing the search page after applying the filter selection
    // so that hero animation target is ready in the `FilterBar`,
    // even when the target is a child of an `AnimatedList`
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
  }

  void _jumpToCollectionPage(BuildContext context, CollectionFilter filter) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: source,
          filters: {filter},
        ),
      ),
      (route) => false,
    );
  }
}

@immutable
class EntryByMimeDatum extends Equatable {
  final String mimeType, displayText;
  final Color color;
  final int entryCount;

  @override
  List<Object?> get props => [mimeType, displayText, color, entryCount];

  const EntryByMimeDatum({
    required this.mimeType,
    required this.displayText,
    required this.color,
    required this.entryCount,
  });
}
