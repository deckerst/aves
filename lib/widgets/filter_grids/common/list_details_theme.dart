import 'dart:math';

import 'package:aves/theme/format.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class FilterListDetailsTheme extends StatelessWidget {
  final double extent;
  final Widget child;

  static const EdgeInsets contentMargin = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 4);
  static const double titleIconPadding = 8;
  static const double titleDetailPadding = 6;

  const FilterListDetailsTheme({
    super.key,
    required this.extent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<MediaQueryData, FilterListDetailsThemeData>(
      update: (context, mq, previous) {
        final use24hour = mq.alwaysUse24HourFormat;
        final textScaler = mq.textScaler;

        final textTheme = Theme.of(context).textTheme;
        var titleStyle = textTheme.bodyMedium!;
        var captionStyle = textTheme.bodySmall!;
        // specify `height` for accurate paragraph height measurement
        final defaultTextHeight = DefaultTextStyle.of(context).style.height;
        titleStyle = titleStyle.copyWith(
          fontSize: textScaler.scale(titleStyle.fontSize!),
          height: titleStyle.height ?? defaultTextHeight,
        );
        captionStyle = captionStyle.copyWith(height: captionStyle.height ?? defaultTextHeight);

        final titleIconSize = textScaler.scale(AvesFilterChip.iconSize);
        final titleLineHeightParagraph = RenderParagraph(
          TextSpan(text: 'Fake Title', style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(const BoxConstraints(), parentUsesSize: true);
        final titleLineHeight = titleLineHeightParagraph.getMaxIntrinsicHeight(double.infinity);
        titleLineHeightParagraph.dispose();

        final captionLineHeightParagraph = RenderParagraph(
          TextSpan(text: formatDateTime(DateTime.now(), context.locale, use24hour), style: captionStyle),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(const BoxConstraints(), parentUsesSize: true);
        final captionLineHeight = captionLineHeightParagraph.getMaxIntrinsicHeight(double.infinity);
        captionLineHeightParagraph.dispose();

        var titleMaxLines = 1;
        var showCount = false;
        var showDate = false;

        final gridExtentMin = context.read<TileExtentController>().effectiveExtentMin;
        final isMinExtent = (extent - gridExtentMin).abs() < precisionErrorTolerance;

        var availableHeight = extent - contentMargin.vertical - contentPadding.vertical;
        final firstTitleLineHeight = max(titleLineHeight, titleIconSize);
        if (availableHeight >= firstTitleLineHeight + titleDetailPadding + captionLineHeight) {
          showCount = true;
          availableHeight -= firstTitleLineHeight + titleDetailPadding + captionLineHeight;
          if (availableHeight >= captionLineHeight) {
            showDate = true;
            availableHeight -= captionLineHeight;
            titleMaxLines += availableHeight ~/ titleLineHeight;
          }
        }

        return FilterListDetailsThemeData(
          extent: extent,
          titleMaxLines: titleMaxLines,
          isMinExtent: isMinExtent,
          showCount: showCount,
          showDate: showDate,
          titleStyle: titleStyle,
          captionStyle: captionStyle,
          titleIconSize: titleIconSize,
          captionIconTheme: IconThemeData(
            color: captionStyle.color,
            size: textScaler.scale(captionStyle.fontSize!),
          ),
        );
      },
      child: child,
    );
  }
}

class FilterListDetailsThemeData {
  final double extent;
  final int titleMaxLines;
  final bool isMinExtent, showCount, showDate;
  final TextStyle titleStyle, captionStyle;
  final double titleIconSize;
  final IconThemeData captionIconTheme;

  const FilterListDetailsThemeData({
    required this.extent,
    required this.titleMaxLines,
    required this.isMinExtent,
    required this.showCount,
    required this.showDate,
    required this.titleStyle,
    required this.captionStyle,
    required this.titleIconSize,
    required this.captionIconTheme,
  });
}
