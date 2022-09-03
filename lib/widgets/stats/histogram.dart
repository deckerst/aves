import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/stats/date/axis.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Histogram extends StatefulWidget {
  final Set<AvesEntry> entries;
  final FilterCallback onFilterSelection;

  const Histogram({
    super.key,
    required this.entries,
    required this.onFilterSelection,
  });

  @override
  State<Histogram> createState() => _HistogramState();
}

class _HistogramState extends State<Histogram> {
  DateLevel _level = DateLevel.y;
  DateTime? _firstDate, _lastDate;
  final Map<DateTime, int> _entryCountPerDate = {};
  final ValueNotifier<EntryByDate?> _selection = ValueNotifier(null);

  static const histogramHeight = 200.0;

  @override
  void initState() {
    super.initState();

    final entriesByDateDescending = List.of(widget.entries)..sort(AvesEntry.compareByDate);
    _lastDate = entriesByDateDescending.firstWhereOrNull((entry) => entry.bestDate != null)?.bestDate;
    _firstDate = entriesByDateDescending.lastWhereOrNull((entry) => entry.bestDate != null)?.bestDate;

    if (_lastDate != null && _firstDate != null) {
      final rangeDays = _lastDate!.difference(_firstDate!).inDays;
      if (rangeDays > 1) {
        if (rangeDays <= 31) {
          _level = DateLevel.ymd;
        } else if (rangeDays <= 365) {
          _level = DateLevel.ym;
        }

        final dates = entriesByDateDescending.map((entry) => entry.bestDate).whereNotNull();
        late DateTime Function(DateTime) groupByKey;
        switch (_level) {
          case DateLevel.ymd:
            groupByKey = (v) => DateTime(v.year, v.month, v.day);
            break;
          case DateLevel.ym:
            groupByKey = (v) => DateTime(v.year, v.month);
            break;
          default:
            groupByKey = (v) => DateTime(v.year);
            break;
        }
        _entryCountPerDate.addAll(groupBy<DateTime, DateTime>(dates, groupByKey).map((k, v) => MapEntry(k, v.length)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entryCountPerDate.isEmpty) return const SizedBox();

    final locale = context.l10n.localeName;
    final numberFormat = NumberFormat.decimalPattern(locale);

    final seriesData = _entryCountPerDate.entries.map((kv) {
      return EntryByDate(date: kv.key, entryCount: kv.value);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: histogramHeight,
          child: Stack(
            children: [
              _buildChart(context, seriesData, drawArea: true),
              _buildChart(context, seriesData, drawArea: false),
            ],
          ),
        ),
        ValueListenableBuilder<EntryByDate?>(
          valueListenable: _selection,
          builder: (context, selection, child) {
            late Widget child;
            if (selection == null) {
              child = const SizedBox();
            } else {
              final filter = DateFilter(_level, selection.date);
              final count = selection.entryCount;
              child = Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    AvesFilterChip(
                      filter: filter,
                      onTap: widget.onFilterSelection,
                    ),
                    const Spacer(),
                    Text(
                      numberFormat.format(count),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.caption!.color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              );
            }

            return AnimatedSwitcher(
              duration: context.read<DurationsData>().formTransition,
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              ),
              child: child,
            );
          },
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<EntryByDate> seriesData, {required bool drawArea}) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final axisColor = charts.ColorUtil.fromDartColor(drawArea ? Colors.transparent : theme.colorScheme.onPrimary.withOpacity(.9));
    final measureLineColor = charts.ColorUtil.fromDartColor(drawArea ? Colors.transparent : theme.colorScheme.onPrimary.withOpacity(.1));
    final histogramLineColor = charts.ColorUtil.fromDartColor(drawArea ? Colors.white : accentColor);
    final histogramPointStrikeColor = axisColor;
    final histogramPointFillColor = charts.ColorUtil.fromDartColor(theme.colorScheme.background);

    final series = [
      charts.Series<EntryByDate, DateTime>(
        id: 'histogramLine',
        data: seriesData,
        domainFn: (d, i) => d.date,
        measureFn: (d, i) => d.entryCount,
        colorFn: (d, i) => histogramLineColor,
      ),
      if (!drawArea)
        charts.Series<EntryByDate, DateTime>(
          id: 'histogramPoints',
          data: seriesData,
          domainFn: (d, i) => d.date,
          measureFn: (d, i) => d.entryCount,
          colorFn: (d, i) => histogramPointStrikeColor,
          fillColorFn: (d, i) => histogramPointFillColor,
        )..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];

    final locale = context.l10n.localeName;
    final timeAxisSpec = _firstDate != null && _lastDate != null
        ? TimeAxisSpec.forLevel(
            locale: locale,
            level: _level,
            first: _firstDate!,
            last: _lastDate!,
          )
        : null;
    final measureFormat = NumberFormat.decimalPattern(locale);

    final domainAxis = charts.DateTimeAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: charts.TextStyleSpec(color: axisColor),
        lineStyle: charts.LineStyleSpec(color: axisColor),
      ),
      tickProviderSpec: timeAxisSpec != null && timeAxisSpec.tickSpecs.isNotEmpty ? charts.StaticDateTimeTickProviderSpec(timeAxisSpec.tickSpecs) : null,
    );

    Widget chart = charts.TimeSeriesChart(
      series,
      domainAxis: domainAxis,
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(color: axisColor),
          lineStyle: charts.LineStyleSpec(color: measureLineColor),
        ),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec((v) {
          // localize and hide 0
          return (v == null || v == 0) ? '' : measureFormat.format(v);
        }),
      ),
      defaultRenderer: charts.LineRendererConfig(
        includeArea: drawArea,
        areaOpacity: 1,
      ),
      customSeriesRenderers: [
        charts.PointRendererConfig(
          customRendererId: 'customPoint',
          radiusPx: 3,
          strokeWidthPx: 2,
          symbolRenderer: charts.CircleSymbolRenderer(isSolid: true),
        ),
      ],
      defaultInteractions: false,
      behaviors: [
        charts.SelectNearest(),
        charts.LinePointHighlighter(
          defaultRadiusPx: 8,
          radiusPaddingPx: 2,
          showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
        ),
      ],
      selectionModels: [
        charts.SelectionModelConfig(
          changedListener: (model) => _selection.value = model.selectedDatum.firstOrNull?.datum as EntryByDate?,
        )
      ],
    );
    if (drawArea) {
      chart = ShaderMask(
        shaderCallback: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withOpacity(0),
            accentColor,
          ],
        ).createShader,
        blendMode: BlendMode.srcIn,
        child: chart,
      );
    }
    return chart;
  }
}

@immutable
class EntryByDate extends Equatable {
  final DateTime date;
  final int entryCount;

  @override
  List<Object?> get props => [date, entryCount];

  const EntryByDate({
    required this.date,
    required this.entryCount,
  });
}
