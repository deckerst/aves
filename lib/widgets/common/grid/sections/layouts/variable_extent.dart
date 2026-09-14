import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class const VariableExtentSectionLayout({
  required super.sectionKey,
  required super.firstIndex,
  required super.lastIndex,
  required super.minOffset,
  required super.maxOffset,
  required super.headerExtent,
  required final List<VariableExtentRowLayout> rows,
  required super.spacing,
  required super.builder,
}) extends SectionLayout {
  @override
  List<Object?> get props => [sectionKey, firstIndex, lastIndex, minOffset, maxOffset, headerExtent, rows, spacing];

  @override
  double indexToLayoutOffset(int index) {
    index -= bodyFirstIndex;
    if (index < 0) return minOffset;
    return bodyMinOffset + (index < rows.length ? rows[index].minOffset : rows.lastOrNull?.maxOffset ?? 0);
  }

  @override
  double indexToMainAxisExtent(int index) {
    index -= bodyFirstIndex;
    if (index < 0) return headerExtent;
    if (index >= rows.length) return 0;
    final row = rows[index];
    return row.maxOffset - row.minOffset;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    return bodyFirstIndex + rows.indexWhere((v) => scrollOffset < v.maxOffset);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    final rowIndex = rows.indexWhere((v) => scrollOffset < v.maxOffset);
    return bodyFirstIndex + (rowIndex == -1 ? rows.length - 1 : rowIndex);
  }
}

class const VariableExtentRowLayout({
  required final int firstIndex,
  required final int lastIndex,
  required final double minOffset,
  required final double height,
  required final List<double> itemWidths,
}) extends Equatable {
  final double maxOffset = minOffset + height;

  @override
  List<Object?> get props => [firstIndex, lastIndex, minOffset, maxOffset, height, itemWidths];
}
