import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/locale/number.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/sections/calendar/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/fixed/row.dart';
import 'package:aves/widgets/common/grid/sections/layouts/variable_extent.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class CalendarSectionLayoutBuilder<T>({
  required super.sections,
  required super.showHeaders,
  required super.getHeaderExtent,
  required super.buildHeader,
  required super.scrollableWidth,
  required super.tileLayout,
  required super.columnCount,
  required super.spacing,
  required super.horizontalPadding,
  required super.tileWidth,
  required super.tileHeight,
  required super.tileBuilder,
  required super.tileAnimationDelay,
  required final MaterialLocalizations localizations,
}) extends SectionLayoutBuilder<T> {
  int _currentIndex = 0;
  double _currentOffset = 0;
  double _weekdayLineHeight = 0;

  static const daysPerWeek = DateTime.daysPerWeek;

  @override
  SectionedListLayout<T> updateLayouts(BuildContext context) {
    _weekdayLineHeight = _DayOfWeekTile.computeLineHeight(context);

    final sectionLayouts = sections.keys
        .map(
          (sectionKey) => buildSectionLayout(
            headerExtent: showHeaders ? getHeaderExtent(context, sectionKey) : 0.0,
            sectionKey: sectionKey,
            section: sections[sectionKey]!,
            animate: animate,
          ),
        )
        .toList();

    return CalendarSectionedListLayout<T>(
      sections: sections,
      showHeaders: showHeaders,
      columnCount: columnCount,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      spacing: spacing,
      horizontalPadding: horizontalPadding,
      sectionLayouts: sectionLayouts,
    );
  }

  @override
  SectionLayout buildSectionLayout({
    required double headerExtent,
    required SectionKey sectionKey,
    required List<T> section,
    required bool animate,
  }) {
    final firstItem = section.firstOrNull;
    if (firstItem == null) throw Exception('empty section for key=$sectionKey');

    final bestDate = firstItem is AvesEntry ? firstItem.bestDate : null;
    if (bestDate == null) throw Exception('section contains undated items for key=$sectionKey');

    final calendar = settings.calendar;
    final calOps = calendar.ops;
    final (year, month) = calOps.getYearMonth(bestDate);

    final locale = settings.avesLocale;
    final calendarDelegate = locale.getDatePickerDelegate();
    final numberFormat = locale.decimalNumberFormat();
    final daysInMonth = calendarDelegate.getDaysInMonth(year, month);
    final dayOffset = calendarDelegate.firstDayOffset(year, month, localizations);

    final itemsByDay = groupBy(section, (v) {
      if (v is! AvesEntry) return null;
      final itemDate = v.bestDate;
      if (itemDate == null) return null;
      final (_, _, day) = calOps.getYearMonthDay(itemDate);
      return day;
    });

    final dayTileBuilders = <WidgetBuilder>[
      ...List.generate(columnCount, (column) {
        final day = (localizations.firstDayOfWeekIndex + column) % columnCount;
        return (context) => _DayOfWeekTile(day: day);
      }),
      ...List.generate(dayOffset + daysInMonth, (column) {
        final day = column - dayOffset + 1;
        return (context) => day < 1
            ? const SizedBox()
            : _DayTile(
                dayToBuild: calendarDelegate.getDay(year, month, day),
                tileWidth: tileWidth,
                dayItem: itemsByDay[day]?.firstOrNull,
                tileBuilder: tileBuilder,
                numberFormat: numberFormat,
              );
      }),
    ];

    final rowCount = (dayTileBuilders.length / columnCount).ceil();
    final sectionChildCount = 1 + rowCount;

    final sectionFirstIndex = _currentIndex;
    _currentIndex += sectionChildCount;
    final sectionLastIndex = _currentIndex - 1;

    final sectionMinOffset = _currentOffset;
    _currentOffset += headerExtent + _weekdayLineHeight + (tileHeight * (rowCount - 1)) + spacing * (rowCount - 1);
    final sectionMaxOffset = _currentOffset;

    final itemWidths = List.generate(columnCount, (_) => tileWidth);
    final rowLayouts = <VariableExtentRowLayout>[];
    int firstIndex = 0;
    double minOffset = 0;
    for (var i = 0; i < rowCount; i++) {
      final isWeekdayHeader = i == 0;
      final lastIndex = firstIndex + columnCount - 1;
      final rowHeight = (isWeekdayHeader ? _weekdayLineHeight : tileHeight) + spacing;
      rowLayouts.add(
        VariableExtentRowLayout(
          firstIndex: firstIndex,
          lastIndex: lastIndex,
          minOffset: minOffset,
          height: rowHeight,
          itemWidths: itemWidths,
        ),
      );
      firstIndex = lastIndex + 1;
      minOffset += rowHeight;
    }

    return VariableExtentSectionLayout(
      sectionKey: sectionKey,
      firstIndex: sectionFirstIndex,
      lastIndex: sectionLastIndex,
      minOffset: sectionMinOffset,
      maxOffset: sectionMaxOffset,
      headerExtent: headerExtent,
      rows: rowLayouts,
      spacing: spacing,
      builder: (context, listIndex) {
        final textDirection = Directionality.of(context);
        final sectionChildIndex = listIndex - sectionFirstIndex;
        final sectionGridIndex = listIndex * columnCount;

        if (sectionChildIndex == 0) {
          final header = headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : const SizedBox();
          return animate ? buildAnimation(context, sectionGridIndex, header) : header;
        }

        final sectionItemCount = dayTileBuilders.length;
        final itemMin = (sectionChildIndex - 1) * columnCount;
        final itemMax = sectionChildIndex * columnCount;
        final minItemIndex = itemMin.clamp(0, sectionItemCount);
        final maxItemIndex = itemMax.clamp(0, sectionItemCount);
        final childrenCount = maxItemIndex - minItemIndex;
        final isWeekdayHeader = minItemIndex < daysPerWeek;
        final children = <Widget>[];
        for (var i = 0; i < childrenCount; i++) {
          final item = RepaintBoundary(
            child: dayTileBuilders[minItemIndex + i](context),
          );
          if (animate) {
            children.add(buildAnimation(context, sectionGridIndex + i, item));
          } else {
            children.add(item);
          }
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FixedExtentGridRow(
            width: tileWidth,
            height: isWeekdayHeader ? _weekdayLineHeight : tileHeight,
            spacing: spacing,
            textDirection: textDirection,
            children: children,
          ),
        );
      },
    );
  }
}

class const _DayOfWeekTile({
  required final int day,
}) extends StatelessWidget {
  static const _padding = EdgeInsets.all(4);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: .center,
      color: Themes.secondLayerColor(context),
      foregroundDecoration: _DayTile.tileDecoration(context),
      child: Text(_narrowWeekdays(context)[day]),
    );
  }

  static double computeLineHeight(BuildContext context) {
    final paragraph = RenderParagraph(
      TextSpan(
        children: _narrowWeekdays(context).map((v) => TextSpan(text: v)).toList(),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final textHeight = paragraph.getMaxIntrinsicHeight(double.infinity);
    paragraph.dispose();
    return textHeight + _padding.vertical;
  }

  static List<String> _narrowWeekdays(BuildContext context) => MaterialLocalizations.of(context).narrowWeekdays;
}

class const _DayTile<T>({
  required final DateTime dayToBuild,
  required final double tileWidth,
  required final T? dayItem,
  required final TileBuilder<T> tileBuilder,
  required final ANumberFormat numberFormat,
}) extends StatelessWidget {
  static List<Shadow> shadows(BuildContext context) => [
    Shadow(
      color: Theme.of(context).isDark ? Colors.black : Colors.white,
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _item = dayItem;
    return Stack(
      children: [
        _item != null
            ? tileBuilder(_item, Size.square(tileWidth))
            : Container(
                color: Themes.secondLayerColor(context),
              ),
        IgnorePointer(
          child: Container(
            alignment: .topStart,
            padding: EdgeInsets.symmetric(horizontal: tileWidth / 25),
            foregroundDecoration: tileDecoration(context),
            child: OutlinedText(
              textSpans: [
                TextSpan(
                  text: numberFormat.format(dayToBuild.day),
                  style: TextStyle(
                    shadows: shadows(context),
                  ),
                ),
              ],
              outlineColor: Themes.firstLayerColor(context),
            ),
          ),
        ),
      ],
    );
  }

  static Decoration tileDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(
          color: DecoratedThumbnail.borderColor(context),
          width: DecoratedThumbnail.borderWidth(context),
        ),
      ),
    );
  }
}
