import 'package:aves/widgets/common/grid/sections/layout/variable_extent_section_layout.dart';
import 'package:collection/collection.dart';

class const SparseVariableExtentSectionLayout({
  required super.sectionKey,
  required super.firstIndex,
  required super.lastIndex,
  required super.minOffset,
  required super.maxOffset,
  required super.headerExtent,
  required super.rows,
  required final Map<int, int> widgetToItemIndexMap,
  required super.spacing,
  required super.builder,
}) extends VariableExtentSectionLayout {
  @override
  int sectionItemIndexToWidgetIndex(int itemIndex) {
    return widgetToItemIndexMap.entries.firstWhereOrNull((kv) => kv.value == itemIndex)?.key ?? -1;
  }

  @override
  int sectionWidgetIndexToItemIndex(int widgetIndex) {
    return widgetToItemIndexMap[widgetIndex] ?? -1;
  }
}
