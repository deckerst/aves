import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/layouts/variable_extent.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class const MosaicSectionedListLayout<T>({
  required super.sections,
  required super.showHeaders,
  required super.spacing,
  required super.horizontalPadding,
  required super.sectionLayouts,
}) extends SectionedListLayout<T> {
  List<VariableExtentRowLayout> _rowsFor(SectionLayout sectionLayout) => (sectionLayout as VariableExtentSectionLayout).rows;

  @override
  Rect? getTileRect(T item) {
    final MapEntry<SectionKey?, List<T>>? section = sections.entries.firstWhereOrNull((kv) => kv.value.contains(item));
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhereOrNull((sl) => sl.sectionKey == sectionKey);
    if (sectionLayout == null) return null;

    final sectionItemIndex = section.value.indexOf(item);
    final row = _rowsFor(sectionLayout).firstWhereOrNull((row) => sectionItemIndex <= row.lastIndex);
    if (row == null) return null;

    final rowItemIndex = sectionItemIndex - row.firstIndex;
    final tileWidth = row.itemWidths[rowItemIndex];
    final tileHeight = row.height - spacing;

    var left = horizontalPadding;
    row.itemWidths.forEachIndexedWhile((i, width) {
      if (i == rowItemIndex) return true;

      left += width + spacing;
      return false;
    });
    final listIndex = sectionLayout.firstIndex + 1 + _rowsFor(sectionLayout).indexOf(row);

    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileWidth, tileHeight);
  }

  @override
  T? getItemAt(Offset position) {
    var dy = position.dy;
    final sectionLayout = getSectionAt(dy);
    if (sectionLayout == null) return null;

    final section = sections[sectionLayout.sectionKey];
    if (section == null) return null;

    dy -= sectionLayout.minOffset + sectionLayout.headerExtent;
    if (dy < 0) return null;

    final row = _rowsFor(sectionLayout).firstWhereOrNull((v) => dy < v.maxOffset);
    if (row == null) return null;

    var dx = position.dx - horizontalPadding;
    var index = -1;
    row.itemWidths.forEachIndexedWhile((i, width) {
      dx -= width + spacing;
      if (dx > 0) return true;

      index = row.firstIndex + i;
      return false;
    });

    if (index < 0 || index >= section.length) return null;
    return section[index];
  }
}
