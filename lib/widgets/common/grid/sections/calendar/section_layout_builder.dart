import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/sections/calendar/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/fixed/row.dart';
import 'package:aves/widgets/common/grid/sections/fixed/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
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

  static const daysPerWeek = DateTime.daysPerWeek;

  @override
  SectionedListLayout<T> updateLayouts(BuildContext context) {
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

    final List<WidgetBuilder> dayTiles = List.generate(daysPerWeek, (column) {
      final dayForColumn = (localizations.firstDayOfWeekIndex + column) % daysPerWeek;
      final String weekday = localizations.narrowWeekdays[dayForColumn];
      return (context) => Center(
        child: Text(weekday),
      );
    });

    final byDay = groupBy(section, (v) {
      if (v is! AvesEntry) return null;
      final itemDate = v.bestDate;
      if (itemDate == null) return null;
      final (_, _, day) = calOps.getYearMonthDay(itemDate);
      return day;
    });

    final itemSize = Size.square(tileWidth);
    final dayTilePadding = EdgeInsets.symmetric(horizontal: tileWidth / 25);

    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayTiles.add((context) => const SizedBox());
      } else {
        final dayToBuild = calendarDelegate.getDay(year, month, day);
        final dayItem = byDay[day]?.firstOrNull;
        dayTiles.add((context) {
          Widget dayTile = IgnorePointer(
            child: Container(
              alignment: AlignmentGeometry.topStart,
              padding: dayTilePadding,
              foregroundDecoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                    color: DecoratedThumbnail.borderColor(context),
                    width: DecoratedThumbnail.borderWidth(context),
                  ),
                ),
              ),
              child: Text(
                numberFormat.format(dayToBuild.day),
                style: TextStyle(
                  shadows: Theme.of(context).isDark ? AStyles.embossShadows : null,
                ),
              ),
            ),
          );
          if (dayItem != null) {
            dayTile = Stack(
              children: [
                tileBuilder(dayItem, itemSize),
                dayTile,
              ],
            );
          }
          return dayTile;
        });
      }
    }

    final rowCount = (dayTiles.length / columnCount).ceil();
    final sectionChildCount = 1 + rowCount;

    final sectionFirstIndex = _currentIndex;
    _currentIndex += sectionChildCount;
    final sectionLastIndex = _currentIndex - 1;

    final sectionMinOffset = _currentOffset;
    _currentOffset += headerExtent + tileHeight * rowCount + spacing * (rowCount - 1);
    final sectionMaxOffset = _currentOffset;

    return FixedExtentSectionLayout(
      sectionKey: sectionKey,
      firstIndex: sectionFirstIndex,
      lastIndex: sectionLastIndex,
      minOffset: sectionMinOffset,
      maxOffset: sectionMaxOffset,
      headerExtent: headerExtent,
      tileHeight: tileHeight,
      spacing: spacing,
      builder: (context, listIndex) {
        final textDirection = Directionality.of(context);
        final sectionChildIndex = listIndex - sectionFirstIndex;
        final sectionGridIndex = listIndex * columnCount;

        if (sectionChildIndex == 0) {
          final header = headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : const SizedBox();
          return animate ? buildAnimation(context, sectionGridIndex, header) : header;
        }

        final sectionItemCount = dayTiles.length;
        final itemMin = (sectionChildIndex - 1) * columnCount;
        final itemMax = sectionChildIndex * columnCount;
        final minItemIndex = itemMin.clamp(0, sectionItemCount);
        final maxItemIndex = itemMax.clamp(0, sectionItemCount);
        final childrenCount = maxItemIndex - minItemIndex;
        final children = <Widget>[];
        for (var i = 0; i < childrenCount; i++) {
          final item = RepaintBoundary(
            child: dayTiles[minItemIndex + i](context),
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
            height: tileHeight,
            spacing: spacing,
            textDirection: textDirection,
            children: children,
          ),
        );
      },
    );
  }
}
