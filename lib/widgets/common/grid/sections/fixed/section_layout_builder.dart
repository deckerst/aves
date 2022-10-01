import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/fixed/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/fixed/row.dart';
import 'package:aves/widgets/common/grid/sections/fixed/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class FixedExtentSectionLayoutBuilder<T> extends SectionLayoutBuilder<T> {
  int _currentIndex = 0;
  double _currentOffset = 0;
  List<Size> _itemSizes;

  FixedExtentSectionLayoutBuilder({
    required super.sections,
    required super.showHeaders,
    required super.getHeaderExtent,
    required super.buildHeader,
    required super.scrollableWidth,
    required super.tileLayout,
    required super.columnCount,
    required super.spacing,
    required super.horizontalPadding,
    required super.tileWidth,
    required super.tileHeight,
    required super.tileBuilder,
    required super.tileAnimationDelay,
  }) : _itemSizes = List.generate(columnCount, (index) => Size(tileWidth, tileHeight));

  @override
  SectionedListLayout<T> updateLayouts(BuildContext context) {
    final sectionLayouts = sections.keys
        .map((sectionKey) => buildSectionLayout(
              headerExtent: showHeaders ? getHeaderExtent(context, sectionKey) : 0.0,
              sectionKey: sectionKey,
              section: sections[sectionKey]!,
              animate: animate,
            ))
        .toList();

    return FixedExtentSectionedListLayout<T>(
      sections: sections,
      showHeaders: showHeaders,
      columnCount: columnCount,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      spacing: spacing,
      horizontalPadding: horizontalPadding,
      sectionLayouts: sectionLayouts,
    );
  }

  @override
  SectionLayout buildSectionLayout({
    required double headerExtent,
    required SectionKey sectionKey,
    required List<T> section,
    required bool animate,
  }) {
    final sectionItemCount = section.length;
    final rowCount = (sectionItemCount / columnCount).ceil();
    final sectionChildCount = 1 + rowCount;

    final sectionFirstIndex = _currentIndex;
    _currentIndex += sectionChildCount;
    final sectionLastIndex = _currentIndex - 1;

    final sectionMinOffset = _currentOffset;
    _currentOffset += headerExtent + tileHeight * rowCount + spacing * (rowCount - 1);
    final sectionMaxOffset = _currentOffset;

    return FixedExtentSectionLayout(
      sectionKey: sectionKey,
      firstIndex: sectionFirstIndex,
      lastIndex: sectionLastIndex,
      minOffset: sectionMinOffset,
      maxOffset: sectionMaxOffset,
      headerExtent: headerExtent,
      tileHeight: tileHeight,
      spacing: spacing,
      builder: (context, listIndex) {
        final textDirection = Directionality.of(context);
        final sectionChildIndex = listIndex - sectionFirstIndex;
        return buildSectionWidget(
          context: context,
          section: section,
          sectionGridIndex: listIndex * columnCount,
          sectionChildIndex: sectionChildIndex,
          itemIndexRange: () => Tuple2(
            (sectionChildIndex - 1) * columnCount,
            sectionChildIndex * columnCount,
          ),
          sectionKey: sectionKey,
          headerExtent: headerExtent,
          itemSizes: _itemSizes,
          animate: animate,
          buildGridRow: (children) => FixedExtentGridRow(
            width: tileWidth,
            height: tileHeight,
            spacing: spacing,
            textDirection: textDirection,
            children: children,
          ),
        );
      },
    );
  }
}
