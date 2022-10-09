import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class MosaicSectionLayout extends SectionLayout {
  final List<MosaicRowLayout> rows;

  @override
  List<Object?> get props => [sectionKey, firstIndex, lastIndex, minOffset, maxOffset, headerExtent, rows, spacing];

  const MosaicSectionLayout({
    required super.sectionKey,
    required super.firstIndex,
    required super.lastIndex,
    required super.minOffset,
    required super.maxOffset,
    required super.headerExtent,
    required this.rows,
    required super.spacing,
    required super.builder,
  });

  @override
  double indexToLayoutOffset(int index) {
    index -= bodyFirstIndex;
    if (index < 0) return minOffset;
    return bodyMinOffset + (index < rows.length ? rows[index].minOffset : rows.lastOrNull?.maxOffset ?? 0);
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

class MosaicRowLayout extends Equatable {
  final int firstIndex, lastIndex;
  final double minOffset, maxOffset, height;
  final List<double> itemWidths;

  @override
  List<Object?> get props => [firstIndex, lastIndex, minOffset, maxOffset, height, itemWidths];

  const MosaicRowLayout({
    required this.firstIndex,
    required this.lastIndex,
    required this.minOffset,
    required this.height,
    required this.itemWidths,
  }) : maxOffset = minOffset + height;
}
