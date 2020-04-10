import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:flutter/material.dart';

// use a `SliverList` instead of multiple `SliverGrid` because having one `SliverGrid` per section does not scale up
// with the multiple `SliverGrid` solution, thumbnails at the beginning of each sections are built even though they are offscreen
// because of `RenderSliverMultiBoxAdaptor.addInitialChild` called by `RenderSliverGrid.performLayout` (line 547), as of Flutter v1.17.0
class CollectionListSliver extends StatelessWidget {
  final CollectionLens collection;
  final bool showHeader;
  final int columnCount;
  final double tileExtent;

  const CollectionListSliver({
    Key key,
    @required this.collection,
    @required this.showHeader,
    @required this.columnCount,
    @required this.tileExtent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sectionLayouts = <_SectionLayout>[];
    final sectionKeys = collection.sections.keys.toList();
    var firstIndex = 0;
    sectionKeys.forEach((sectionKey) {
      final sectionEntryCount = collection.sections[sectionKey].length;
      final rowCount = (sectionEntryCount / columnCount).ceil();
      final widgetCount = rowCount + (showHeader ? 1 : 0);
      // closure of `firstIndex` on `sectionFirstIndex`
      final sectionFirstIndex = firstIndex;
      sectionLayouts.add(
        _SectionLayout(
          sectionKey: sectionKey,
          widgetCount: widgetCount,
          firstIndex: sectionFirstIndex,
          builder: (context, listIndex) {
            listIndex -= sectionFirstIndex;
            if (showHeader) {
              if (listIndex == 0) {
                return SectionHeader(
                  collection: collection,
                  sections: collection.sections,
                  sectionKey: sectionKey,
                );
              }
              listIndex--;
            }

            final section = collection.sections[sectionKey];
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
      firstIndex += widgetCount;
    });
    final childCount = firstIndex;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= childCount) return null;
          final sectionLayout = sectionLayouts.firstWhere((section) => section.hasChild(index));
          return sectionLayout.builder(context, index);
        },
        childCount: childCount,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

class _SectionLayout {
  final dynamic sectionKey;
  final int widgetCount;
  final int firstIndex;
  final int lastIndex;
  final IndexedWidgetBuilder builder;

  const _SectionLayout({
    @required this.sectionKey,
    @required this.widgetCount,
    @required this.firstIndex,
    @required this.builder,
  }) : lastIndex = firstIndex + widgetCount - 1;

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;
}
