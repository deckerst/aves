import 'dart:math';

import 'package:aves/labs/sliver_known_extent_list.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:aves/widgets/album/grid/header_generic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// use a `SliverList` instead of multiple `SliverGrid` because having one `SliverGrid` per section does not scale up
// with the multiple `SliverGrid` solution, thumbnails at the beginning of each sections are built even though they are offscreen
// because of `RenderSliverMultiBoxAdaptor.addInitialChild` called by `RenderSliverGrid.performLayout` (line 547), as of Flutter v1.17.0
class CollectionListSliver extends StatelessWidget {
  final CollectionLens collection;
  final bool showHeader;
  final double scrollableWidth;
  final int columnCount;
  final double tileExtent;

  CollectionListSliver({
    Key key,
    @required this.collection,
    @required this.showHeader,
    @required this.scrollableWidth,
    @required this.tileExtent,
  })  : columnCount = (scrollableWidth / tileExtent).round(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final sectionLayouts = <SectionLayout>[];
    final source = collection.source;
    final sections = collection.sections;
    final sectionKeys = sections.keys.toList();
    var currentIndex = 0, currentOffset = 0.0;
    sectionKeys.forEach((sectionKey) {
      final sectionEntryCount = sections[sectionKey].length;
      final sectionChildCount = 1 + (sectionEntryCount / columnCount).ceil();

      final headerExtent = showHeader ? SectionHeader.computeHeaderHeight(source, sectionKey, scrollableWidth) : 0.0;

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
          builder: (context, listIndex) {
            listIndex -= sectionFirstIndex;
            if (listIndex == 0) {
              return showHeader
                  ? SectionHeader(
                      collection: collection,
                      sections: sections,
                      sectionKey: sectionKey,
                    )
                  : const SizedBox.shrink();
            }
            listIndex--;

            final section = sections[sectionKey];
            final minEntryIndex = listIndex * columnCount;
            final maxEntryIndex = min(sectionEntryCount, minEntryIndex + columnCount);
            final children = <Widget>[];
            for (var i = minEntryIndex; i < maxEntryIndex; i++) {
              children.add(GridThumbnail(
                collection: collection,
                index: i,
                entry: section[i],
                tileExtent: tileExtent,
              ));
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
          },
        ),
      );
    });
    final childCount = currentIndex;

    return SliverKnownExtentList(
      sectionLayouts: sectionLayouts,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= childCount) return null;
          final sectionLayout = sectionLayouts.firstWhere((section) => section.hasChild(index), orElse: () => null);
          return sectionLayout?.builder(context, index) ?? const SizedBox.shrink();
        },
        childCount: childCount,
        addAutomaticKeepAlives: false,
      ),
    );
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
