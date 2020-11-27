import 'dart:math';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/stats/filter_table.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StatsPage extends StatelessWidget {
  static const routeName = '/collection/stats';

  final CollectionSource source;
  final CollectionLens parentCollection;
  final Map<String, int> entryCountPerCountry = {}, entryCountPerPlace = {}, entryCountPerTag = {};

  List<ImageEntry> get entries => parentCollection?.sortedEntries ?? source.rawEntries;

  static const mimeDonutMinWidth = 124.0;

  StatsPage({
    @required this.source,
    this.parentCollection,
  }) : assert(source != null) {
    entries.forEach((entry) {
      if (entry.isLocated) {
        final address = entry.addressDetails;
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
      entry.xmpSubjects.forEach((tag) {
        entryCountPerTag[tag] = (entryCountPerTag[tag] ?? 0) + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (entries.isEmpty) {
      child = EmptyContent(
        icon: AIcons.image,
        text: 'No images',
      );
    } else {
      final byMimeTypes = groupBy<ImageEntry, String>(entries, (entry) => entry.mimeType).map<String, int>((k, v) => MapEntry(k, v.length));
      final imagesByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('image/')));
      final videoByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('video/')));
      final mimeDonuts = Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildMimeDonut(context, (sum) => Intl.plural(sum, one: 'image', other: 'images'), imagesByMimeTypes),
          _buildMimeDonut(context, (sum) => Intl.plural(sum, one: 'video', other: 'videos'), videoByMimeTypes),
        ],
      );

      final catalogued = entries.where((entry) => entry.isCatalogued);
      final withGps = catalogued.where((entry) => entry.hasGps);
      final withGpsPercent = withGps.length / entries.length;
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final lineHeight = 16 * textScaleFactor;
      final locationIndicator = Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            LinearPercentIndicator(
              percent: withGpsPercent,
              lineHeight: lineHeight,
              backgroundColor: Colors.white24,
              progressColor: Theme.of(context).accentColor,
              animation: true,
              leading: Icon(AIcons.location),
              // right padding to match leading, so that inside label is aligned with outside label below
              padding: EdgeInsets.symmetric(horizontal: lineHeight) + EdgeInsets.only(right: 24),
              center: Text(
                NumberFormat.percentPattern().format(withGpsPercent),
                style: TextStyle(shadows: [Constants.embossShadow]),
              ),
            ),
            SizedBox(height: 8),
            Text('${withGps.length} ${Intl.plural(withGps.length, one: 'item', other: 'items')} with location'),
          ],
        ),
      );
      child = ListView(
        children: [
          mimeDonuts,
          locationIndicator,
          ..._buildTopFilters(context, 'Top Countries', entryCountPerCountry, (s) => LocationFilter(LocationLevel.country, s)),
          ..._buildTopFilters(context, 'Top Places', entryCountPerPlace, (s) => LocationFilter(LocationLevel.place, s)),
          ..._buildTopFilters(context, 'Top Tags', entryCountPerTag, (s) => TagFilter(s)),
        ],
      );
    }
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stats'),
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }

  Widget _buildMimeDonut(BuildContext context, String Function(num) label, Map<String, num> byMimeTypes) {
    if (byMimeTypes.isEmpty) return SizedBox.shrink();

    final sum = byMimeTypes.values.fold<int>(0, (prev, v) => prev + v);

    final seriesData = byMimeTypes.entries.map((kv) => EntryByMimeDatum(mimeType: kv.key, entryCount: kv.value)).toList();
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

      final donut = Container(
        width: dim,
        height: dim,
        child: Stack(
          children: [
            charts.PieChart(
              series,
              defaultRenderer: charts.ArcRendererConfig(
                arcWidth: 16,
              ),
            ),
            Center(
              child: Text(
                '$sum\n${label(sum)}',
                textAlign: TextAlign.center,
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
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(end: 8),
                              child: Icon(AIcons.disc, color: d.color),
                            ),
                          ),
                          TextSpan(text: '${d.displayText}   '),
                          TextSpan(text: '${d.entryCount}', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      maxLines: 1,
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

  List<Widget> _buildTopFilters(
    BuildContext context,
    String title,
    Map<String, int> entryCountMap,
    CollectionFilter Function(String key) filterBuilder,
  ) {
    if (entryCountMap.isEmpty) return [];

    return [
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          title,
          style: Constants.titleTextStyle,
        ),
      ),
      FilterTable(
        totalEntryCount: entries.length,
        entryCountMap: entryCountMap,
        filterBuilder: filterBuilder,
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
    parentCollection.addFilter(filter);
    // we post closing the search page after applying the filter selection
    // so that hero animation target is ready in the `FilterBar`,
    // even when the target is a child of an `AnimatedList`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
  }

  void _jumpToCollectionPage(BuildContext context, CollectionFilter filter) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(CollectionLens(
          source: source,
          filters: [filter],
          groupFactor: settings.collectionGroupFactor,
          sortFactor: settings.collectionSortFactor,
        )),
      ),
      (route) => false,
    );
  }
}

class EntryByMimeDatum {
  final String mimeType;
  final String displayText;
  final int entryCount;

  EntryByMimeDatum({
    @required this.mimeType,
    @required this.entryCount,
  }) : displayText = MimeUtils.displayType(mimeType);

  Color get color => stringToColor(displayText);

  @override
  String toString() {
    return '[$runtimeType#${shortHash(this)}: mimeType=$mimeType, displayText=$displayText, entryCount=$entryCount]';
  }
}
