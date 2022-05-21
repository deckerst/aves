import 'dart:math';

import 'package:aves/theme/format.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
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
        final locale = context.l10n.localeName;

        final use24hour = mq.alwaysUse24HourFormat;
        final textScaleFactor = mq.textScaleFactor;

        final textTheme = Theme.of(context).textTheme;
        final titleStyleBase = textTheme.bodyText2!;
        final titleStyle = titleStyleBase.copyWith(fontSize: titleStyleBase.fontSize! * textScaleFactor);
        final captionStyle = textTheme.caption!;

        final titleIconSize = AvesFilterChip.iconSize * textScaleFactor;
        final titleLineHeight = (RenderParagraph(
          TextSpan(text: 'Fake Title', style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaleFactor: textScaleFactor,
        )..layout(const BoxConstraints(), parentUsesSize: true))
            .getMaxIntrinsicHeight(double.infinity);

        final captionLineHeight = (RenderParagraph(
          TextSpan(text: formatDateTime(DateTime.now(), locale, use24hour), style: captionStyle),
          textDirection: TextDirection.ltr,
          textScaleFactor: textScaleFactor,
          strutStyle: Constants.overflowStrutStyle,
        )..layout(const BoxConstraints(), parentUsesSize: true))
            .getMaxIntrinsicHeight(double.infinity);

        var titleMaxLines = 1;
        var showCount = false;
        var showDate = false;

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
          showCount: showCount,
          showDate: showDate,
          titleStyle: titleStyle,
          captionStyle: captionStyle,
          titleIconSize: titleIconSize,
          captionIconTheme: IconThemeData(
            color: captionStyle.color,
            size: captionStyle.fontSize! * textScaleFactor,
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
  final bool showCount, showDate;
  final TextStyle titleStyle, captionStyle;
  final double titleIconSize;
  final IconThemeData captionIconTheme;

  const FilterListDetailsThemeData({
    required this.extent,
    required this.titleMaxLines,
    required this.showCount,
    required this.showDate,
    required this.titleStyle,
    required this.captionStyle,
    required this.titleIconSize,
    required this.captionIconTheme,
  });
}
