import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class CalendarSectionedListLayout<T> extends SectionedListLayout<T> {
  final int columnCount;
  final double tileWidth, tileHeight;

  const new({
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
    // TODO TLAD [calendar]
    return null;
  }

  @override
  T? getItemAt(Offset position) {
    // TODO TLAD [calendar]
    return null;
  }
}
