import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class FilterTable extends StatelessWidget {
  final CollectionLens collection;
  final Map<String, int> entryCountMap;
  final CollectionFilter Function(String key) filterBuilder;

  const FilterTable({
    @required this.collection,
    @required this.entryCountMap,
    @required this.filterBuilder,
  });

  static const chipWidth = AvesFilterChip.maxChipWidth;
  static const countWidth = 32.0;
  static const percentIndicatorMinWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    final maxCount = collection.entryCount;
    final sortedEntries = entryCountMap.entries.toList()
      ..sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : compareAsciiUpperCase(kv1.key, kv2.key);
      });

    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final lineHeight = 16 * textScaleFactor;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: AvesFilterChip.outlineWidth / 2 + 6, end: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showPercentIndicator = constraints.maxWidth - (chipWidth + countWidth) > percentIndicatorMinWidth;
          return Table(
            children: sortedEntries.take(5).map((kv) {
              final filter = filterBuilder(kv.key);
              final label = filter.label;
              final count = kv.value;
              final percent = count / maxCount;
              return TableRow(
                children: [
                  Container(
                    // the `Table` `border` property paints on the cells and does not add margins,
                    // so we define margins here instead, but they should be symmetric
                    // to keep all cells vertically aligned on the center/middle
                    margin: EdgeInsets.symmetric(vertical: 4),
                    alignment: AlignmentDirectional.centerStart,
                    child: AvesFilterChip(
                      filter: filter,
                      onTap: (filter) => _goToCollection(context, filter),
                    ),
                  ),
                  if (showPercentIndicator)
                    LinearPercentIndicator(
                      percent: percent,
                      lineHeight: lineHeight,
                      backgroundColor: Colors.white24,
                      progressColor: stringToColor(label),
                      animation: true,
                      padding: EdgeInsets.symmetric(horizontal: lineHeight),
                      center: Text(
                        NumberFormat.percentPattern().format(percent),
                        style: TextStyle(shadows: [Constants.embossShadow]),
                      ),
                    ),
                  Text(
                    '$count',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.end,
                  ),
                ],
              );
            }).toList(),
            columnWidths: {
              0: MaxColumnWidth(IntrinsicColumnWidth(), FixedColumnWidth(chipWidth)),
              2: MaxColumnWidth(IntrinsicColumnWidth(), FixedColumnWidth(countWidth)),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          );
        },
      ),
    );
  }

  void _goToCollection(BuildContext context, CollectionFilter filter) {
    if (collection == null) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(collection.derive(filter)),
      ),
      settings.navRemoveRoutePredicate(CollectionPage.routeName),
    );
  }
}
