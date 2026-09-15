import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/layout/variable_extent_section_layout.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class const VariableExtentSectionedListLayout<T>({
  required super.sections,
  required super.showHeaders,
  required super.spacing,
  required super.horizontalPadding,
  required super.sectionLayouts,
}) extends SectionedListLayout<T> {
  @override
  Rect? getTileRect(T item) {
    final MapEntry<SectionKey?, List<T>>? section = sections.entries.firstWhereOrNull((kv) => kv.value.contains(item));
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhereOrNull((sl) => sl.sectionKey == sectionKey);
    if (sectionLayout is! VariableExtentSectionLayout) return null;

    final sectionItemIndex = section.value.indexOf(item);
    final sectionWidgetIndex = sectionLayout.sectionItemIndexToWidgetIndex(sectionItemIndex);

    final rows = sectionLayout.rows;
    final rowIndex = rows.indexWhere((row) => sectionWidgetIndex <= row.lastIndex);
    if (rowIndex == -1) return null;

    final row = rows[rowIndex];
    final rowItemIndex = sectionWidgetIndex - row.firstIndex;
    final rowItemWidths = row.itemWidths;
    final tileWidth = rowItemWidths[rowItemIndex];
    final tileHeight = row.height - spacing;

    var left = horizontalPadding;
    rowItemWidths.forEachIndexedWhile((i, width) {
      if (i == rowItemIndex) return true;

      left += width + spacing;
      return false;
    });
    final listIndex = sectionLayout.firstIndex + 1 + rowIndex;

    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileWidth, tileHeight);
  }

  @override
  T? getItemAt(Offset position) {
    var dy = position.dy;
    final sectionLayout = getSectionAt(dy);
    if (sectionLayout is! VariableExtentSectionLayout) return null;

    final section = sections[sectionLayout.sectionKey];
    if (section == null) return null;

    dy -= sectionLayout.minOffset + sectionLayout.headerExtent;
    if (dy < 0) return null;

    final row = sectionLayout.rows.firstWhereOrNull((v) => dy < v.maxOffset);
    if (row == null) return null;

    var dx = position.dx - horizontalPadding;
    var widgetIndex = -1;
    row.itemWidths.forEachIndexedWhile((i, width) {
      dx -= width + spacing;
      if (dx > 0) return true;

      widgetIndex = row.firstIndex + i;
      return false;
    });

    final itemIndex = sectionLayout.sectionWidgetIndexToItemIndex(widgetIndex);
    if (itemIndex < 0 || itemIndex >= section.length) return null;
    return section[itemIndex];
  }
}
