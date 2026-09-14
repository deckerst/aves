import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

class const CalendarSectionedListLayout<T>({
  required super.sections,
  required super.showHeaders,
  required final int columnCount,
  required final double tileWidth,
  required final double tileHeight,
  required super.spacing,
  required super.horizontalPadding,
  required super.sectionLayouts,
}) extends SectionedListLayout<T> {
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
