import 'package:flutter/material.dart';

class SectionLayout {
  final dynamic sectionKey;
  final int firstIndex, lastIndex;
  final double minOffset, maxOffset;
  final double headerExtent, tileExtent;
  final IndexedWidgetBuilder builder;

  const SectionLayout({
    @required this.sectionKey,
    @required this.firstIndex,
    @required this.lastIndex,
    @required this.minOffset,
    @required this.maxOffset,
    @required this.headerExtent,
    @required this.tileExtent,
    @required this.builder,
  });

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;

  bool hasChildAtOffset(double scrollOffset) => minOffset <= scrollOffset && scrollOffset <= maxOffset;

  double indexToLayoutOffset(int index) {
    return minOffset + (index == firstIndex ? 0 : headerExtent + (index - firstIndex - 1) * tileExtent);
  }

  double indexToMaxScrollOffset(int index) {
    return minOffset + headerExtent + (index - firstIndex) * tileExtent;
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= minOffset + headerExtent;
    return firstIndex + (scrollOffset < 0 ? 0 : (scrollOffset / tileExtent).floor());
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= minOffset + headerExtent;
    return firstIndex + (scrollOffset < 0 ? 0 : (scrollOffset / tileExtent).ceil() - 1);
  }
}
