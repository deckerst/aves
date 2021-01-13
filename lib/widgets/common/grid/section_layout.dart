import 'dart:math';

import 'package:aves/model/source/section_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class SectionedListLayoutProvider<T> extends StatelessWidget {
  final double scrollableWidth;
  final int columnCount;
  final double tileExtent;
  final Widget Function(T entry) tileBuilder;
  final Widget child;

  const SectionedListLayoutProvider({
    @required this.scrollableWidth,
    @required this.columnCount,
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
    final showHeaders = needHeaders();
    final sections = getSections();
    final sectionKeys = sections.keys.toList();

    final sectionLayouts = <SectionLayout>[];
    var currentIndex = 0, currentOffset = 0.0;
    sectionKeys.forEach((sectionKey) {
      final section = sections[sectionKey];
      final sectionEntryCount = section.length;
      final sectionChildCount = 1 + (sectionEntryCount / columnCount).ceil();

      final headerExtent = showHeaders ? getHeaderExtent(context, sectionKey) : 0.0;

      final sectionFirstIndex = currentIndex;
      currentIndex += sectionChildCount;
      final sectionLastIndex = currentIndex - 1;

      final sectionMinOffset = currentOffset;
      currentOffset += headerExtent + tileExtent * (sectionChildCount - 1);
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
          builder: (context, listIndex) => _buildInSection(
            context,
            section,
            listIndex - sectionFirstIndex,
            sectionKey,
            headerExtent,
          ),
        ),
      );
    });
    return SectionedListLayout<T>(
      sections: sections,
      showHeaders: showHeaders,
      columnCount: columnCount,
      tileExtent: tileExtent,
      sectionLayouts: sectionLayouts,
    );
  }

  Widget _buildInSection(BuildContext context, List<T> section, int sectionChildIndex, SectionKey sectionKey, double headerExtent) {
    if (sectionChildIndex == 0) {
      return headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : SizedBox.shrink();
    }
    sectionChildIndex--;

    final sectionEntryCount = section.length;

    final minEntryIndex = sectionChildIndex * columnCount;
    final maxEntryIndex = min(sectionEntryCount, minEntryIndex + columnCount);
    final children = <Widget>[];
    for (var i = minEntryIndex; i < maxEntryIndex; i++) {
      final entry = section[i];
      children.add(tileBuilder(entry));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  bool needHeaders();

  Map<SectionKey, List<T>> getSections();

  double getHeaderExtent(BuildContext context, SectionKey sectionKey);

  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent);
}

class SectionedListLayout<T> {
  final Map<SectionKey, List<T>> sections;
  final bool showHeaders;
  final int columnCount;
  final double tileExtent;
  final List<SectionLayout> sectionLayouts;

  const SectionedListLayout({
    @required this.sections,
    @required this.showHeaders,
    @required this.columnCount,
    @required this.tileExtent,
    @required this.sectionLayouts,
  });

  Rect getTileRect(T entry) {
    final section = sections.entries.firstWhere((kv) => kv.value.contains(entry), orElse: () => null);
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhere((sl) => sl.sectionKey == sectionKey, orElse: () => null);
    if (sectionLayout == null) return null;

    final sectionEntryIndex = section.value.indexOf(entry);
    final column = sectionEntryIndex % columnCount;
    final row = (sectionEntryIndex / columnCount).floor();
    final listIndex = sectionLayout.firstIndex + (showHeaders ? 1 : 0) + row;

    final left = tileExtent * column;
    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileExtent, tileExtent);
  }

  T getEntryAt(Offset position) {
    var dy = position.dy;
    final sectionLayout = sectionLayouts.firstWhere((sl) => dy < sl.maxOffset, orElse: () => null);
    if (sectionLayout == null) return null;

    final section = sections[sectionLayout.sectionKey];
    if (section == null) return null;

    dy -= sectionLayout.minOffset + sectionLayout.headerExtent;
    if (dy < 0) return null;

    final row = dy ~/ tileExtent;
    final column = position.dx ~/ tileExtent;
    final index = row * columnCount + column;
    if (index >= section.length) return null;

    return section[index];
  }
}

class SectionLayout {
  final SectionKey sectionKey;
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

  @override
  String toString() => '$runtimeType#${shortHash(this)}{sectionKey=$sectionKey, firstIndex=$firstIndex, lastIndex=$lastIndex, minOffset=$minOffset, maxOffset=$maxOffset, headerExtent=$headerExtent}';
}
