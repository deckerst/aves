import 'dart:math';

import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

abstract class SectionedListLayoutProvider<T> extends StatelessWidget {
  final double scrollableWidth;
  final int columnCount;
  final double spacing, tileExtent;
  final Widget Function(T item) tileBuilder;
  final Widget child;

  const SectionedListLayoutProvider({
    @required this.scrollableWidth,
    @required this.columnCount,
    this.spacing = 0,
    @required this.tileExtent,
    @required this.tileBuilder,
    @required this.child,
  }) : assert(scrollableWidth != 0);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider0<SectionedListLayout<T>>(
      update: (context, __) => _updateLayouts(context),
      child: child,
    );
  }

  SectionedListLayout<T> _updateLayouts(BuildContext context) {
    final _showHeaders = showHeaders;
    final _sections = sections;
    final sectionKeys = _sections.keys.toList();

    final sectionLayouts = <SectionLayout>[];
    var currentIndex = 0, currentOffset = 0.0;
    sectionKeys.forEach((sectionKey) {
      final section = _sections[sectionKey];
      final sectionItemCount = section.length;
      final rowCount = (sectionItemCount / columnCount).ceil();
      final sectionChildCount = 1 + rowCount;

      final headerExtent = _showHeaders ? getHeaderExtent(context, sectionKey) : 0.0;

      final sectionFirstIndex = currentIndex;
      currentIndex += sectionChildCount;
      final sectionLastIndex = currentIndex - 1;

      final sectionMinOffset = currentOffset;
      currentOffset += headerExtent + tileExtent * rowCount + spacing * (rowCount - 1);
      final sectionMaxOffset = currentOffset;

      sectionLayouts.add(
        SectionLayout(
          sectionKey: sectionKey,
          firstIndex: sectionFirstIndex,
          lastIndex: sectionLastIndex,
          minOffset: sectionMinOffset,
          maxOffset: sectionMaxOffset,
          headerExtent: headerExtent,
          tileExtent: tileExtent,
          spacing: spacing,
          builder: (context, listIndex) => _buildInSection(
            context,
            section,
            listIndex * columnCount,
            listIndex - sectionFirstIndex,
            sectionKey,
            headerExtent,
          ),
        ),
      );
    });
    return SectionedListLayout<T>(
      sections: _sections,
      showHeaders: _showHeaders,
      columnCount: columnCount,
      tileExtent: tileExtent,
      spacing: spacing,
      sectionLayouts: sectionLayouts,
    );
  }

  Widget _buildInSection(
    BuildContext context,
    List<T> section,
    int sectionGridIndex,
    int sectionChildIndex,
    SectionKey sectionKey,
    double headerExtent,
  ) {
    if (sectionChildIndex == 0) {
      final header = headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : SizedBox.shrink();
      return _buildAnimation(sectionGridIndex, header);
    }
    sectionChildIndex--;

    final sectionItemCount = section.length;

    final minItemIndex = sectionChildIndex * columnCount;
    final maxItemIndex = min(sectionItemCount, minItemIndex + columnCount);
    final children = <Widget>[];
    for (var i = minItemIndex; i < maxItemIndex; i++) {
      final itemGridIndex = sectionGridIndex + i - minItemIndex;
      final item = tileBuilder(section[i]);
      if (i != minItemIndex) children.add(SizedBox(width: spacing));
      children.add(_buildAnimation(itemGridIndex, item));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildAnimation(int index, Widget child) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: columnCount,
      duration: Durations.staggeredAnimation,
      delay: Durations.staggeredAnimationDelay,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }

  bool get showHeaders;

  Map<SectionKey, List<T>> get sections;

  double getHeaderExtent(BuildContext context, SectionKey sectionKey);

  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent);
}

class SectionedListLayout<T> {
  final Map<SectionKey, List<T>> sections;
  final bool showHeaders;
  final int columnCount;
  final double tileExtent, spacing;
  final List<SectionLayout> sectionLayouts;

  const SectionedListLayout({
    @required this.sections,
    @required this.showHeaders,
    @required this.columnCount,
    @required this.tileExtent,
    @required this.spacing,
    @required this.sectionLayouts,
  });

  Rect getTileRect(T item) {
    final section = sections.entries.firstWhere((kv) => kv.value.contains(item), orElse: () => null);
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhere((sl) => sl.sectionKey == sectionKey, orElse: () => null);
    if (sectionLayout == null) return null;

    final sectionItemIndex = section.value.indexOf(item);
    final column = sectionItemIndex % columnCount;
    final row = (sectionItemIndex / columnCount).floor();
    final listIndex = sectionLayout.firstIndex + 1 + row;

    final left = tileExtent * column + spacing * (column - 1);
    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileExtent, tileExtent);
  }

  T getItemAt(Offset position) {
    var dy = position.dy;
    final sectionLayout = sectionLayouts.firstWhere((sl) => dy < sl.maxOffset, orElse: () => null);
    if (sectionLayout == null) return null;

    final section = sections[sectionLayout.sectionKey];
    if (section == null) return null;

    dy -= sectionLayout.minOffset + sectionLayout.headerExtent;
    if (dy < 0) return null;

    final row = dy ~/ (tileExtent + spacing);
    final column = position.dx ~/ (tileExtent + spacing);
    final index = row * columnCount + column;
    if (index >= section.length) return null;

    return section[index];
  }
}

class SectionLayout {
  final SectionKey sectionKey;
  final int firstIndex, lastIndex, bodyFirstIndex;
  final double minOffset, maxOffset, bodyMinOffset;
  final double headerExtent, tileExtent, spacing, mainAxisStride;
  final IndexedWidgetBuilder builder;

  const SectionLayout({
    @required this.sectionKey,
    @required this.firstIndex,
    @required this.lastIndex,
    @required this.minOffset,
    @required this.maxOffset,
    @required this.headerExtent,
    @required this.tileExtent,
    @required this.spacing,
    @required this.builder,
  })  : bodyFirstIndex = firstIndex + 1,
        bodyMinOffset = minOffset + headerExtent,
        mainAxisStride = tileExtent + spacing;

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;

  bool hasChildAtOffset(double scrollOffset) => minOffset <= scrollOffset && scrollOffset <= maxOffset;

  double indexToLayoutOffset(int index) {
    index -= bodyFirstIndex;
    if (index < 0) return minOffset;
    return bodyMinOffset + index * mainAxisStride;
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    return bodyFirstIndex + scrollOffset ~/ mainAxisStride;
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    return bodyFirstIndex + (scrollOffset / mainAxisStride).ceil() - 1;
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{sectionKey=$sectionKey, firstIndex=$firstIndex, lastIndex=$lastIndex, minOffset=$minOffset, maxOffset=$maxOffset, headerExtent=$headerExtent, tileExtent=$tileExtent, spacing=$spacing}';
}
