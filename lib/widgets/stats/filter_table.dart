import 'package:aves/model/filters/filters.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:percent_indicator/linear_percent_indicator.dart';

class FilterTable<T extends Comparable> extends StatelessWidget {
  final int totalEntryCount;
  final Map<T, int> entryCountMap;
  final CollectionFilter Function(T key) filterBuilder;
  final bool sortByCount;
  final int? maxRowCount;
  final FilterCallback onFilterSelection;

  const FilterTable({
    Key? key,
    required this.totalEntryCount,
    required this.entryCountMap,
    required this.filterBuilder,
    required this.sortByCount,
    required this.maxRowCount,
    required this.onFilterSelection,
  }) : super(key: key);

  static const chipWidth = AvesFilterChip.defaultMaxChipWidth;
  static const countWidth = 32.0;
  static const percentIndicatorMinWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = entryCountMap.entries.toList();
    if (sortByCount) {
      sortedEntries.sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : kv1.key.compareTo(kv2.key);
      });
    }

    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final lineHeight = 16 * textScaleFactor;
    final isRtl = context.isRtl;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AvesFilterChip.outlineWidth / 2 + 6, end: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showPercentIndicator = constraints.maxWidth - (chipWidth + countWidth) > percentIndicatorMinWidth;
          final displayedEntries = maxRowCount != null ? sortedEntries.take(maxRowCount!) : sortedEntries;
          return Table(
            children: displayedEntries.map((kv) {
              final filter = filterBuilder(kv.key);
              final label = filter.getLabel(context);
              final count = kv.value;
              final percent = count / totalEntryCount;
              return TableRow(
                children: [
                  Container(
                    // the `Table` `border` property paints on the cells and does not add margins,
                    // so we define margins here instead, but they should be symmetric
                    // to keep all cells vertically aligned on the center/middle
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: AlignmentDirectional.centerStart,
                    child: AvesFilterChip(
                      filter: filter,
                      onTap: onFilterSelection,
                    ),
                  ),
                  if (showPercentIndicator)
                    LinearPercentIndicator(
                      percent: percent,
                      lineHeight: lineHeight,
                      backgroundColor: Colors.white24,
                      progressColor: stringToColor(label),
                      animation: true,
                      isRTL: isRtl,
                      // TODO TLAD handle low percents being rendered with wrong radius clip
                      barRadius: Radius.circular(lineHeight / 2),
                      center: Text(
                        intl.NumberFormat.percentPattern().format(percent),
                        style: const TextStyle(shadows: Constants.embossShadows),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: lineHeight),
                    ),
                  Text(
                    '$count',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.end,
                  ),
                ],
              );
            }).toList(),
            columnWidths: const {
              0: MaxColumnWidth(IntrinsicColumnWidth(), FixedColumnWidth(chipWidth)),
              2: MaxColumnWidth(IntrinsicColumnWidth(), FixedColumnWidth(countWidth)),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          );
        },
      ),
    );
  }
}
