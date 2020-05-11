import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/stats/filter_table.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StatsPage extends StatelessWidget {
  final CollectionLens collection;
  final Map<String, int> entryCountPerCountry = {}, entryCountPerPlace = {}, entryCountPerTag = {};

  List<ImageEntry> get entries => collection.sortedEntries;

  static const mimeDonutMinWidth = 124.0;

  StatsPage({this.collection}) {
    entries.forEach((entry) {
      if (entry.isLocated) {
        final address = entry.addressDetails;
        var country = address.countryName;
        if (country != null && country.isNotEmpty) {
          country += ';${address.countryCode}';
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
    if (collection.isEmpty) {
      child = const EmptyContent();
    } else {
      final catalogued = entries.where((entry) => entry.isCatalogued);
      final withGps = catalogued.where((entry) => entry.hasGps);
      final withGpsPercent = withGps.length / collection.entryCount;
      final byMimeTypes = groupBy(entries, (entry) => entry.mimeType).map<String, int>((k, v) => MapEntry(k, v.length));
      final imagesByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('image/')));
      final videoByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('video/')));
      child = ListView(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              _buildMimeDonut(context, (sum) => Intl.plural(sum, one: 'image', other: 'images'), imagesByMimeTypes),
              _buildMimeDonut(context, (sum) => Intl.plural(sum, one: 'video', other: 'videos'), videoByMimeTypes),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearPercentIndicator(
                  percent: withGpsPercent,
                  lineHeight: 16,
                  backgroundColor: Colors.white24,
                  progressColor: Theme.of(context).accentColor,
                  animation: true,
                  leading: const Icon(AIcons.location),
                  // right padding to match leading, so that inside label is aligned with outside label below
                  padding: const EdgeInsets.symmetric(horizontal: 16) + const EdgeInsets.only(right: 24),
                  center: Text(NumberFormat.percentPattern().format(withGpsPercent)),
                ),
                const SizedBox(height: 8),
                Text('${withGps.length} ${Intl.plural(withGps.length, one: 'item', other: 'items')} with location'),
              ],
            ),
          ),
          ..._buildTopFilters('Top Countries', entryCountPerCountry, (s) => LocationFilter(LocationLevel.country, s)),
          ..._buildTopFilters('Top Places', entryCountPerPlace, (s) => LocationFilter(LocationLevel.place, s)),
          ..._buildTopFilters('Top Tags', entryCountPerTag, (s) => TagFilter(s)),
        ],
      );
    }
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }

  String _cleanMime(String mime) {
    mime = mime.toUpperCase().replaceFirst(RegExp('.*/(X-)?'), '').replaceFirst('+XML', '');
    return mime;
  }

  Widget _buildMimeDonut(BuildContext context, String Function(num) label, Map<String, num> byMimeTypes) {
    if (byMimeTypes.isEmpty) return const SizedBox.shrink();

    final sum = byMimeTypes.values.fold(0, (prev, v) => prev + v);

    final seriesData = byMimeTypes.entries.map((kv) => StringNumDatum(_cleanMime(kv.key), kv.value)).toList();
    seriesData.sort((kv1, kv2) {
      final c = kv2.value.compareTo(kv1.value);
      return c != 0 ? c : compareAsciiUpperCase(kv1.key, kv2.key);
    });

    final series = [
      charts.Series<StringNumDatum, String>(
        id: 'mime',
        colorFn: (d, i) => charts.ColorUtil.fromDartColor(stringToColor(d.key)),
        domainFn: (d, i) => d.key,
        measureFn: (d, i) => d.value,
        data: seriesData,
        labelAccessorFn: (d, _) => '${d.key}: ${d.value}',
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final dim = max(mimeDonutMinWidth, availableWidth / (availableWidth > 4 * mimeDonutMinWidth ? 4 : 2));

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
                '${sum}\n${label(sum)}',
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
              .map((kv) => RichText(
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: Icon(AIcons.disc, color: stringToColor(kv.key)),
                          ),
                        ),
                        TextSpan(text: '${kv.key}   '),
                        TextSpan(text: '${kv.value}', style: const TextStyle(color: Colors.white70)),
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
      return availableWidth > mimeDonutMinWidth * 2
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
    String title,
    Map<String, int> entryCountMap,
    CollectionFilter Function(String key) filterBuilder,
  ) {
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
        collection: collection,
        entryCountMap: entryCountMap,
        filterBuilder: filterBuilder,
      ),
    ];
  }
}

class StringNumDatum {
  final String key;
  final num value;

  const StringNumDatum(this.key, this.value);

  @override
  String toString() {
    return '[$runtimeType#$hashCode: key=$key, value=$value]';
  }
}
