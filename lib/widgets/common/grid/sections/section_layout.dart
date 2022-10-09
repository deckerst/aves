import 'package:aves/model/source/section_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class SectionLayout extends Equatable {
  final SectionKey sectionKey;
  final int firstIndex, lastIndex, bodyFirstIndex;
  final double minOffset, maxOffset, bodyMinOffset;
  final double headerExtent, spacing;
  final IndexedWidgetBuilder builder;

  @override
  List<Object?> get props => [sectionKey, firstIndex, lastIndex, minOffset, maxOffset, headerExtent, spacing];

  const SectionLayout({
    required this.sectionKey,
    required this.firstIndex,
    required this.lastIndex,
    required this.minOffset,
    required this.maxOffset,
    required this.headerExtent,
    required this.spacing,
    required this.builder,
  })  : bodyFirstIndex = firstIndex + 1,
        bodyMinOffset = minOffset + headerExtent;

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;

  bool hasChildAtOffset(double scrollOffset) => minOffset <= scrollOffset && scrollOffset <= maxOffset;

  double indexToLayoutOffset(int index);

  int getMinChildIndexForScrollOffset(double scrollOffset);

  int getMaxChildIndexForScrollOffset(double scrollOffset);
}
