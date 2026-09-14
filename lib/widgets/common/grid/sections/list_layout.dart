import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

abstract class const SectionedListLayout<T>({
  required final Map<SectionKey, List<T>> sections,
  required final bool showHeaders,
  required final double spacing,
  required final double horizontalPadding,
  required final List<SectionLayout> sectionLayouts,
}) {
  // returns tile rectangle in layout space, i.e. x=0 is start
  Rect? getTileRect(T item);

  SectionLayout? getSectionAt(double offsetY) => sectionLayouts.firstWhereOrNull((sl) => offsetY < sl.maxOffset);

  // `position` in layout space, i.e. x=0 is start
  T? getItemAt(Offset position);
}
