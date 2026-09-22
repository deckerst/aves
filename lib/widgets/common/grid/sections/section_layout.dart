import 'package:aves/model/source/section_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

@immutable
abstract class const SectionLayout({
  required final SectionKey sectionKey,
  required final int firstIndex,
  required final int lastIndex,
  required final double minOffset,
  required final double maxOffset,
  required final double headerExtent,
  required final double spacing,
  required final IndexedWidgetBuilder builder,
}) extends Equatable {
  final int bodyFirstIndex = firstIndex + 1;
  final double bodyMinOffset = minOffset + headerExtent;

  @override
  List<Object?> get props => [sectionKey, firstIndex, lastIndex, minOffset, maxOffset, headerExtent, spacing];

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;

  bool hasChildAtOffset(double scrollOffset) => minOffset <= scrollOffset && scrollOffset <= maxOffset;

  double indexToLayoutOffset(int index);

  double indexToMainAxisExtent(int index);

  int getMinChildIndexForScrollOffset(double scrollOffset);

  int getMaxChildIndexForScrollOffset(double scrollOffset);
}
