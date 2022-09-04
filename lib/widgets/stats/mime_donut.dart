import 'dart:math';

import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MimeDonut extends StatefulWidget {
  final IconData icon;
  final Map<String, int> byMimeTypes;
  final Duration animationDuration;
  final FilterCallback onFilterSelection;

  const MimeDonut({
    super.key,
    required this.icon,
    required this.byMimeTypes,
    required this.animationDuration,
    required this.onFilterSelection,
  });

  @override
  State<MimeDonut> createState() => _MimeDonutState();
}

class _MimeDonutState extends State<MimeDonut> with AutomaticKeepAliveClientMixin {
  Map<String, int> get byMimeTypes => widget.byMimeTypes;

  static const mimeDonutMinWidth = 124.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (byMimeTypes.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final locale = l10n.localeName;
    final numberFormat = NumberFormat.decimalPattern(locale);

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
                  Icon(widget.icon),
                  Text(
                    numberFormat.format(sum),
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
                    onTap: () => widget.onFilterSelection(MimeFilter(d.mimeType)),
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
                          numberFormat.format(d.entryCount),
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

  @override
  bool get wantKeepAlive => true;
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
