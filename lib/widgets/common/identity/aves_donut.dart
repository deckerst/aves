import 'dart:math';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef DatumKeyFormatter = String Function(AvesDonutDatum d);
typedef DatumValueFormatter = String Function(int d);
typedef DatumColorizer = Color Function(AvesDonutDatum d);
typedef DatumCallback = void Function(AvesDonutDatum d);

class AvesDonut extends StatefulWidget {
  final Widget title;
  final Map<String, int> byTypes;
  final Duration animationDuration;
  final DatumKeyFormatter formatKey;
  final DatumValueFormatter formatValue;
  final DatumColorizer colorize;
  final DatumCallback? onTap;

  const AvesDonut({
    super.key,
    required this.title,
    required this.byTypes,
    required this.animationDuration,
    required this.formatKey,
    required this.formatValue,
    required this.colorize,
    this.onTap,
  });

  @override
  State<AvesDonut> createState() => _AvesDonutState();
}

class _AvesDonutState extends State<AvesDonut> with AutomaticKeepAliveClientMixin {
  Map<String, int> get byTypes => widget.byTypes;

  DatumKeyFormatter get formatKey => widget.formatKey;

  DatumValueFormatter get formatValue => widget.formatValue;

  DatumColorizer get colorize => widget.colorize;

  static const avesDonutMinWidth = 124.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (byTypes.isEmpty) return const SizedBox();

    final sum = byTypes.values.sum;

    final seriesData = byTypes.entries.map((kv) {
      final type = kv.key;
      return AvesDonutDatum(
        key: type,
        value: kv.value,
      );
    }).toList();
    seriesData.sort((d1, d2) {
      final c = d2.value.compareTo(d1.value);
      return c != 0 ? c : compareAsciiUpperCase(formatKey(d1), formatKey(d2));
    });

    final series = [
      charts.Series<AvesDonutDatum, String>(
        id: 'type',
        colorFn: (d, i) => charts.ColorUtil.fromDartColor(colorize(d)),
        domainFn: (d, i) => formatKey(d),
        measureFn: (d, i) => d.value,
        data: seriesData,
        labelAccessorFn: (d, _) => '${formatKey(d)}: ${d.value}',
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final minWidth = avesDonutMinWidth * textScaleFactor;
      final availableWidth = constraints.maxWidth;
      final dim = max(minWidth, availableWidth / (availableWidth > 4 * minWidth ? 4 : (availableWidth > 2 * minWidth ? 2 : 1)));

      final donut = SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          children: [
            charts.PieChart(
              series,
              animate: context.select<Settings, bool>((v) => v.accessibilityAnimations.animate),
              animationDuration: widget.animationDuration,
              defaultRenderer: charts.ArcRendererConfig<String>(
                arcWidth: 16,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.title,
                  Text(
                    formatValue(sum),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      final onTap = widget.onTap;
      final legend = SizedBox(
        width: dim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: seriesData
              .map((d) => InkWell(
                    onTap: onTap != null ? () => onTap(d) : null,
                    borderRadius: const BorderRadius.all(Radius.circular(123)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AIcons.disc, color: colorize(d)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formatKey(d),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatValue(d.value),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                        const SizedBox(width: 4),
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

  @override
  bool get wantKeepAlive => true;
}

@immutable
class AvesDonutDatum extends Equatable {
  final String key;
  final int value;

  @override
  List<Object?> get props => [key, value];

  const AvesDonutDatum({
    required this.key,
    required this.value,
  });
}
