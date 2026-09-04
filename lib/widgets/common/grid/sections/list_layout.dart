import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

abstract class SectionedListLayout<T> {
  final Map<SectionKey, List<T>> sections;
  final bool showHeaders;
  final double spacing, horizontalPadding;
  final List<SectionLayout> sectionLayouts;

  const new({
    required this.sections,
    required this.showHeaders,
    required this.spacing,
    required this.horizontalPadding,
    required this.sectionLayouts,
  });

  // returns tile rectangle in layout space, i.e. x=0 is start
  Rect? getTileRect(T item);

  SectionLayout? getSectionAt(double offsetY) => sectionLayouts.firstWhereOrNull((sl) => offsetY < sl.maxOffset);

  // `position` in layout space, i.e. x=0 is start
  T? getItemAt(Offset position);
}
