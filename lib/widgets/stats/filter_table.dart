import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/stats/percent_text.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class FilterTable<T extends Comparable> extends StatelessWidget {
  final int totalEntryCount;
  final Map<T, int> entryCountMap;
  final CollectionFilter Function(T key) filterBuilder;
  final bool sortByCount;
  final int? maxRowCount;
  final FilterCallback onFilterSelection;

  const FilterTable({
    super.key,
    required this.totalEntryCount,
    required this.entryCountMap,
    required this.filterBuilder,
    required this.sortByCount,
    required this.maxRowCount,
    required this.onFilterSelection,
  });

  static const chipWidth = 160.0;
  static const countWidth = 32.0;
  static const percentIndicatorMinWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    final countFormatter = NumberFormat.decimalPattern(context.locale);
    final animate = context.select<Settings, bool>((v) => v.animate);

    final sortedEntries = entryCountMap.entries.toList();
    if (sortByCount) {
      sortedEntries.sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : kv1.key.compareTo(kv2.key);
      });
    }

    final textScaler = MediaQuery.textScalerOf(context);
    final lineHeight = textScaler.scale(16);
    final barRadius = Radius.circular(lineHeight / 2);
    final isRtl = context.isRtl;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AvesFilterChip.outlineWidth / 2 + 6, end: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showPercentIndicator = constraints.maxWidth - (chipWidth + countWidth) > percentIndicatorMinWidth;
          final displayedEntries = maxRowCount != null ? sortedEntries.take(maxRowCount!) : sortedEntries;
          final isMonochrome = settings.themeColorMode == AvesThemeColorMode.monochrome;
          return Table(
            children: displayedEntries.map((kv) {
              final filter = filterBuilder(kv.key);
              final count = kv.value;
              final percent = count / totalEntryCount;
              final colorScheme = Theme.of(context).colorScheme;
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
                    FutureBuilder<Color>(
                      future: filter.color(context),
                      builder: (context, snapshot) {
                        final color = snapshot.data;
                        return Stack(
                          // use a stack instead of `center` field, so that the widgets
                          // are centered even when the center child has larger height
                          alignment: Alignment.center,
                          children: [
                            LinearPercentIndicator(
                              percent: percent,
                              lineHeight: lineHeight,
                              backgroundColor: Themes.secondLayerColor(context),
                              progressColor: isMonochrome ? colorScheme.primary : color,
                              animation: animate,
                              isRTL: isRtl,
                              barRadius: barRadius,
                              padding: EdgeInsets.symmetric(horizontal: lineHeight),
                            ),
                            LinearPercentIndicatorText(percent: percent),
                          ],
                        );
                      },
                    ),
                  Text(
                    countFormatter.format(count),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
