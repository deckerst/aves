import 'dart:math';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/modules/app.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin FilterQuickChooserMixin<T> {
  List<T> get options;

  static const int maxTotalOptionCount = AppSettings.recentFilterHistoryMax;
  static const double _chipPadding = AvesFilterChip.defaultPadding;
  static const bool _chipAllowGenericIcon = false;

  CollectionFilter buildFilter(BuildContext context, T option);

  Widget itemBuilder(BuildContext context, T option) {
    return AvesFilterChip(
      filter: buildFilter(context, option),
      allowGenericIcon: _chipAllowGenericIcon,
      padding: _chipPadding,
      maxWidth: double.infinity,
    );
  }

  double computeItemHeight(BuildContext context) => AvesFilterChip.minChipHeight;

  double? computeLargestItemWidth(BuildContext context) {
    if (options.isEmpty) return null;

    final textStyle = DefaultTextStyle.of(context).style.copyWith(
          fontSize: AvesFilterChip.fontSize,
        );
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = textScaler.scale(AvesFilterChip.iconSize);

    return options.map((option) {
      final filter = buildFilter(context, option);
      final icon = filter.iconBuilder(context, iconSize, allowGenericIcon: _chipAllowGenericIcon);
      final label = filter.getLabel(context);
      final paragraph = RenderParagraph(
        TextSpan(text: label, style: textStyle),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout(const BoxConstraints(), parentUsesSize: true);
      final labelWidth = paragraph.getMaxIntrinsicWidth(double.infinity);
      double chipWidth = labelWidth + _chipPadding * 4;
      if (icon != null) {
        chipWidth += iconSize + _chipPadding;
      }
      return max(AvesFilterChip.minChipWidth, chipWidth);
    }).reduce(max);
  }
}
