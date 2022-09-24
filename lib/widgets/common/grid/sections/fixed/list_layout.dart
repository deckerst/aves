import 'dart:math';

import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FixedExtentSectionedListLayout<T> extends SectionedListLayout<T> {
  final int columnCount;
  final double tileWidth, tileHeight;

  const FixedExtentSectionedListLayout({
    required super.sections,
    required super.showHeaders,
    required this.columnCount,
    required this.tileWidth,
    required this.tileHeight,
    required super.spacing,
    required super.horizontalPadding,
    required super.sectionLayouts,
  });

  @override
  Rect? getTileRect(T item) {
    final MapEntry<SectionKey?, List<T>>? section = sections.entries.firstWhereOrNull((kv) => kv.value.contains(item));
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhereOrNull((sl) => sl.sectionKey == sectionKey);
    if (sectionLayout == null) return null;

    final sectionItemIndex = section.value.indexOf(item);
    final column = sectionItemIndex % columnCount;
    final row = (sectionItemIndex / columnCount).floor();
    final listIndex = sectionLayout.firstIndex + 1 + row;

    final left = horizontalPadding + tileWidth * column + spacing * (column - 1);
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

    final row = dy ~/ (tileHeight + spacing);
    final column = max(0, position.dx - horizontalPadding) ~/ (tileWidth + spacing);
    final index = row * columnCount + column;
    if (index >= section.length) return null;

    return section[index];
  }
}
