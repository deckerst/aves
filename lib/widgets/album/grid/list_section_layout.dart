import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/grid/header_generic.dart';
import 'package:aves/widgets/album/grid/tile_extent_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SectionedListLayoutProvider extends StatelessWidget {
  final CollectionLens collection;
  final int columnCount;
  final double scrollableWidth;
  final double tileExtent;
  final Widget Function(ImageEntry entry) thumbnailBuilder;
  final Widget child;

  SectionedListLayoutProvider({
    @required this.collection,
    @required this.scrollableWidth,
    @required this.tileExtent,
    @required this.thumbnailBuilder,
    @required this.child,
  }) : columnCount = max((scrollableWidth / tileExtent).round(), TileExtentManager.columnCountMin);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider0<SectionedListLayout>(
      update: (context, __) => _updateLayouts(context),
      child: child,
    );
  }

  SectionedListLayout _updateLayouts(BuildContext context) {
    debugPrint('$runtimeType _updateLayouts entries=${collection.entryCount} columnCount=$columnCount tileExtent=$tileExtent');
    final sectionLayouts = <SectionLayout>[];
    final showHeaders = collection.showHeaders;
    final source = collection.source;
    final sections = collection.sections;
    final sectionKeys = sections.keys.toList();
    var currentIndex = 0, currentOffset = 0.0;
    sectionKeys.forEach((sectionKey) {
      final sectionEntryCount = sections[sectionKey].length;
      final sectionChildCount = 1 + (sectionEntryCount / columnCount).ceil();

      final headerExtent = showHeaders ? SectionHeader.computeHeaderHeight(source, sectionKey, scrollableWidth) : 0.0;

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
          builder: (context, listIndex) => _buildInSection(listIndex - sectionFirstIndex, collection, sectionKey),
        ),
      );
    });
    return SectionedListLayout(
      collection: collection,
      columnCount: columnCount,
      tileExtent: tileExtent,
      sectionLayouts: sectionLayouts,
    );
  }

  Widget _buildInSection(int sectionChildIndex, CollectionLens collection, dynamic sectionKey) {
    if (sectionChildIndex == 0) {
      return collection.showHeaders
          ? SectionHeader(
              collection: collection,
              sectionKey: sectionKey,
            )
          : const SizedBox.shrink();
    }
    sectionChildIndex--;

    final section = collection.sections[sectionKey];
    final sectionEntryCount = section.length;

    final minEntryIndex = sectionChildIndex * columnCount;
    final maxEntryIndex = min(sectionEntryCount, minEntryIndex + columnCount);
    final children = <Widget>[];
    for (var i = minEntryIndex; i < maxEntryIndex; i++) {
      final entry = section[i];
      children.add(thumbnailBuilder(entry));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class SectionedListLayout {
  final CollectionLens collection;
  final int columnCount;
  final double tileExtent;
  final List<SectionLayout> sectionLayouts;

  const SectionedListLayout({
    @required this.collection,
    @required this.columnCount,
    @required this.tileExtent,
    @required this.sectionLayouts,
  });

  Rect getTileRect(ImageEntry entry) {
    final section = collection.sections.entries.firstWhere((kv) => kv.value.contains(entry), orElse: () => null);
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhere((sl) => sl.sectionKey == sectionKey, orElse: () => null);
    if (sectionLayout == null) return null;

    final showHeaders = collection.showHeaders;
    final sectionEntryIndex = section.value.indexOf(entry);
    final column = sectionEntryIndex % columnCount;
    final row = (sectionEntryIndex / columnCount).floor();
    final listIndex = sectionLayout.firstIndex + (showHeaders ? 1 : 0) + row;

    final left = tileExtent * column;
    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileExtent, tileExtent);
  }

  int rowIndex(dynamic sectionKey, List<int> builtIds) {
    if (!collection.sections.containsKey(sectionKey)) return null;

    final section = collection.sections[sectionKey];
    final firstId = builtIds.first;
    final firstIndexInSection = section.indexWhere((entry) => entry.contentId == firstId);
    if (firstIndexInSection % columnCount != 0) return null;

    final collectionIds = section.skip(firstIndexInSection).take(builtIds.length).map((entry) => entry.contentId);
    final eq = const IterableEquality().equals;
    if (eq(builtIds, collectionIds)) {
      final sectionLayout = sectionLayouts.firstWhere((section) => section.sectionKey == sectionKey, orElse: () => null);
      if (sectionLayout == null) return null;
      return sectionLayout.firstIndex + 1 + firstIndexInSection ~/ columnCount;
    }

    return null;
  }
}

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
