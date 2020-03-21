import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  final CollectionLens collection;

  const StatsPage({this.collection});

  List<ImageEntry> get entries => collection.sortedEntries;

  @override
  Widget build(BuildContext context) {
    final catalogued = entries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final Map<String, int> byMimeTypes = groupBy(entries, (entry) => entry.mimeType).map((k, v) => MapEntry(k, v.length));
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  _buildMimePie(context, 'images', Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('image/')))),
                  _buildMimePie(context, 'videos', Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('video/')))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: withGps.length / entries.length),
                    const SizedBox(height: 8),
                    Text('${withGps.length} entries with location'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMimePie(BuildContext context, String label, Map<String, num> byMimeTypes) {
    if (byMimeTypes.isEmpty) return const SizedBox.shrink();

    final seriesData = byMimeTypes.entries.map((kv) => StringNumDatum(kv.key.replaceFirst(RegExp('.*/'), '').toUpperCase(), kv.value)).toList();
    seriesData.sort((kv1, kv2) => kv2.value.compareTo(kv1.value));

    final series = [
      charts.Series<StringNumDatum, String>(
        id: label,
        colorFn: (d, i) => charts.ColorUtil.fromDartColor(stringToColor(d.key)),
        domainFn: (d, i) => d.key,
        measureFn: (d, i) => d.value,
        data: seriesData,
        labelAccessorFn: (d, _) => '${d.key}: ${d.value}',
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      var mq = MediaQuery.of(context);
      final dim = constraints.maxWidth / (mq.orientation == Orientation.portrait ? 2 : 4);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
                    '${byMimeTypes.values.fold(0, (prev, v) => prev + v)}\n$label',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: dim,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: seriesData
                    .map((kv) => Row(
                          children: [
                            Icon(Icons.fiber_manual_record, color: stringToColor(kv.key)),
                            const SizedBox(width: 8),
                            Text(kv.key),
                            const SizedBox(width: 8),
                            Text('${kv.value}', style: const TextStyle(color: Colors.white70)),
                          ],
                        ))
                    .toList()),
          ),
        ],
      );
    });
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
