import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/calendar/day_of_week_tile.dart';
import 'package:aves/widgets/common/grid/sections/calendar/day_tile.dart';
import 'package:aves/widgets/common/grid/sections/layout/fixed_extent_grid_row.dart';
import 'package:aves/widgets/common/grid/sections/layout/sparse_variable_extent_section_layout.dart';
import 'package:aves/widgets/common/grid/sections/layout/variable_extent_section_layout.dart';
import 'package:aves/widgets/common/grid/sections/layout/variable_extent_sectioned_list_layout.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
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
    _weekdayLineHeight = DayOfWeekTile.computeLineHeight(context);

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

    return VariableExtentSectionedListLayout<T>(
      sections: sections,
      showHeaders: showHeaders,
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

    final itemByDay = groupBy(section, (v) {
      if (v is! AvesEntry) return null;
      final itemDate = v.bestDate;
      if (itemDate == null) return null;
      final (_, _, day) = calOps.getYearMonthDay(itemDate);
      return day;
    }).map((k, v) => MapEntry(k, v.firstOrNull)).whereNotNullValue().whereNotNullKey();

    final widgetIndexOffset = columnCount + dayOffset - 1;
    final widgetToItemIndexMap = itemByDay.map((k, v) {
      final itemIndex = section.indexOf(v);
      return MapEntry(k + widgetIndexOffset, itemIndex > -1 ? itemIndex : null);
    }).whereNotNullValue();

    final dayTileBuilders = <WidgetBuilder>[
      ...List.generate(columnCount, (column) {
        final day = (localizations.firstDayOfWeekIndex + column) % columnCount;
        return (context) => DayOfWeekTile(day: day);
      }),
      ...List.generate(dayOffset + daysInMonth, (column) {
        final day = column - dayOffset + 1;
        return (context) => day < 1
            ? const SizedBox()
            : DayTile(
                dayToBuild: calendarDelegate.getDay(year, month, day),
                tileWidth: tileWidth,
                dayItem: itemByDay[day],
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

    return SparseVariableExtentSectionLayout(
      sectionKey: sectionKey,
      firstIndex: sectionFirstIndex,
      lastIndex: sectionLastIndex,
      minOffset: sectionMinOffset,
      maxOffset: sectionMaxOffset,
      headerExtent: headerExtent,
      rows: rowLayouts,
      widgetToItemIndexMap: widgetToItemIndexMap,
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
