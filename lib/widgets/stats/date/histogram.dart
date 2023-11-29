import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/stats/date/axis.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Histogram extends StatefulWidget {
  final Set<AvesEntry> entries;
  final Duration animationDuration;
  final FilterCallback onFilterSelection;

  const Histogram({
    super.key,
    required this.entries,
    required this.animationDuration,
    required this.onFilterSelection,
  });

  @override
  State<Histogram> createState() => _HistogramState();
}

class _HistogramState extends State<Histogram> with AutomaticKeepAliveClientMixin {
  DateLevel _level = DateLevel.y;
  DateTime? _firstDate, _lastDate;
  final Map<DateTime, int> _entryCountPerDate = {};
  final ValueNotifier<_EntryByDate?> _selection = ValueNotifier(null);
  List<_EntryByDate>? _seriesData;
  late Future<List<_EntryByDate>?> _interpolatedDataLoader;
  late Future<void> _areaChartLoader;

  static const histogramHeight = 200.0;

  Duration get animationDuration => widget.animationDuration;

  @override
  void initState() {
    super.initState();

    final entriesByDateDescending = List.of(widget.entries)..sort(AvesEntrySort.compareByDate);
    var lastDate = entriesByDateDescending.firstWhereOrNull((entry) => entry.bestDate != null)?.bestDate;
    var firstDate = entriesByDateDescending.lastWhereOrNull((entry) => entry.bestDate != null)?.bestDate;

    if (lastDate != null && firstDate != null) {
      final rangeDays = lastDate.difference(firstDate).inDays;
      if (rangeDays > 1) {
        if (rangeDays <= 31) {
          _level = DateLevel.ymd;
        } else if (rangeDays <= 365) {
          _level = DateLevel.ym;
        }

        late DateTime Function(DateTime) normalizeDate;
        switch (_level) {
          case DateLevel.ymd:
            normalizeDate = (v) => DateTime(v.year, v.month, v.day);
          case DateLevel.ym:
            normalizeDate = (v) => DateTime(v.year, v.month);
          default:
            normalizeDate = (v) => DateTime(v.year);
        }
        _firstDate = normalizeDate(firstDate);
        _lastDate = normalizeDate(lastDate);

        final dates = entriesByDateDescending.map((entry) => entry.bestDate).whereNotNull();
        _entryCountPerDate.addAll(groupBy<DateTime, DateTime>(dates, normalizeDate).map((k, v) => MapEntry(k, v.length)));
        if (_entryCountPerDate.isNotEmpty) {
          // discrete points
          _seriesData = _entryCountPerDate.entries.map((kv) {
            return _EntryByDate(date: kv.key, entryCount: kv.value);
          }).toList();

          // smooth curve
          _interpolatedDataLoader = compute<_DataInterpolationArg, List<_EntryByDate>?>(
              _computeInterpolatedData,
              _DataInterpolationArg(
                firstDate: _firstDate,
                lastDate: _lastDate,
                level: _level,
                entryCountPerDate: _entryCountPerDate,
              ));
          _areaChartLoader = _interpolatedDataLoader.then((_) => Future.delayed(animationDuration * timeDilation));
        }
      }
    }
  }

  static List<_EntryByDate>? _computeInterpolatedData(_DataInterpolationArg arg) {
    final firstDate = arg.firstDate;
    final lastDate = arg.lastDate;
    final level = arg.level;
    final entryCountPerDate = arg.entryCountPerDate;

    if (firstDate == null || lastDate == null) return null;

    final xRange = lastDate.difference(firstDate);
    final xRangeInMillis = xRange.inMilliseconds;
    late int xCount;
    late DateTime Function(DateTime date) incrementDate;
    switch (level) {
      case DateLevel.ymd:
        xCount = xRange.inDays;
        incrementDate = (date) => DateTime(date.year, date.month, date.day + 1);
      case DateLevel.ym:
        xCount = (xRange.inDays / 30.5).round();
        incrementDate = (date) => DateTime(date.year, date.month + 1);
      default:
        xCount = lastDate.year - firstDate.year;
        incrementDate = (date) => DateTime(date.year + 1);
    }
    final yMax = entryCountPerDate.values.reduce(max).toDouble();
    final xInterval = yMax / xCount;
    final controlPoints = <Offset>[];
    var date = firstDate;
    for (int i = 0; i <= xCount; i++) {
      controlPoints.add(Offset(i * xInterval, (entryCountPerDate[date] ?? 0).toDouble()));
      date = incrementDate(date);
    }
    final interpolatedPoints = controlPoints.length > 3 ? CatmullRomSpline(controlPoints).generateSamples().map((sample) => sample.value).toList() : controlPoints;
    final interpolatedData = interpolatedPoints.map((p) {
      final date = firstDate.add(Duration(milliseconds: p.dx * xRangeInMillis ~/ yMax));
      final entryCount = p.dy.clamp(0, yMax);
      return _EntryByDate(date: date, entryCount: entryCount);
    }).toList();

    return interpolatedData;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_seriesData == null) return const SizedBox();

    return FutureBuilder<List<_EntryByDate>?>(
      future: _interpolatedDataLoader,
      builder: (context, snapshot) {
        final interpolatedData = snapshot.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: histogramHeight,
              child: AnimatedSwitcher(
                duration: animationDuration,
                child: interpolatedData != null
                    ? Stack(
                        children: [
                          FutureBuilder<void>(
                            future: _areaChartLoader,
                            builder: (context, snapshot) {
                              Widget child = const SizedBox();
                              if (snapshot.connectionState == ConnectionState.done) {
                                child = _buildChart(context, interpolatedData, isInterpolated: true, isArea: true);
                              }
                              return AnimatedSwitcher(
                                duration: animationDuration,
                                child: child,
                              );
                            },
                          ),
                          _buildChart(context, interpolatedData, isInterpolated: true, isArea: false),
                          _buildChart(context, _seriesData!, isInterpolated: false, isArea: false),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
            _buildSelectionRow(),
          ],
        );
      },
    );
  }

  Widget _buildChart(BuildContext context, List<_EntryByDate> seriesData, {required bool isInterpolated, required bool isArea}) {
    final drawArea = isInterpolated && isArea;
    final drawLine = isInterpolated && !isArea;
    final drawPoints = !isInterpolated;

    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.primary;
    final axisColor = charts.ColorUtil.fromDartColor(drawPoints ? colorScheme.onPrimary.withOpacity(.9) : Colors.transparent);
    final measureLineColor = charts.ColorUtil.fromDartColor(drawPoints ? colorScheme.onPrimary.withOpacity(.1) : Colors.transparent);
    final histogramLineColor = charts.ColorUtil.fromDartColor(drawLine ? accentColor : Colors.white);
    final histogramPointStrikeColor = axisColor;
    final histogramPointFillColor = charts.ColorUtil.fromDartColor(colorScheme.background);

    final series = [
      if (drawLine || drawArea)
        charts.Series<_EntryByDate, DateTime>(
          id: 'curve',
          data: seriesData,
          domainFn: (d, i) => d.date,
          measureFn: (d, i) => d.entryCount,
          colorFn: (d, i) => histogramLineColor,
        ),
      if (drawPoints && !drawArea)
        charts.Series<_EntryByDate, DateTime>(
          id: 'points',
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
      animate: false,
      animationDuration: animationDuration,
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
          strokeWidthPx: 2,
          symbolRenderer: _CircleSymbolRenderer(isSolid: false),
        ),
      ],
      defaultInteractions: false,
      behaviors: drawPoints
          ? [
              charts.SelectNearest(),
              charts.LinePointHighlighter(
                defaultRadiusPx: 8,
                radiusPaddingPx: 2,
                showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
                showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
              ),
            ]
          : null,
      selectionModels: [
        charts.SelectionModelConfig(
          changedListener: (model) => _selection.value = model.selectedDatum.firstOrNull?.datum as _EntryByDate?,
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

  Widget _buildSelectionRow() {
    final locale = context.l10n.localeName;
    final numberFormat = NumberFormat.decimalPattern(locale);

    return ValueListenableBuilder<_EntryByDate?>(
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          transitionBuilder: AvesTransitions.formTransitionBuilder,
          child: child,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

@immutable
class _EntryByDate extends Equatable {
  final DateTime date;
  final num entryCount;

  @override
  List<Object?> get props => [date, entryCount];

  const _EntryByDate({
    required this.date,
    required this.entryCount,
  });
}

class _CircleSymbolRenderer extends charts.CircleSymbolRenderer {
  _CircleSymbolRenderer({super.isSolid = true});

  @override
  charts.Color? getSolidFillColor(charts.Color? fillColor) => fillColor;
}

class _DataInterpolationArg {
  final DateLevel level;
  final DateTime? firstDate, lastDate;
  final Map<DateTime, int> entryCountPerDate;

  const _DataInterpolationArg({
    required this.level,
    required this.firstDate,
    required this.lastDate,
    required this.entryCountPerDate,
  });
}
