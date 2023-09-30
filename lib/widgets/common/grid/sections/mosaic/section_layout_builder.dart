import 'dart:math';

import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/row.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/provider.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MosaicSectionLayoutBuilder<T> extends SectionLayoutBuilder<T> {
  int _currentIndex = 0;
  double _currentOffset = 0;
  late double Function(int itemCount) rowAvailableWidth;
  late double rowHeightMax;
  final CoverRatioResolver<T> coverRatioResolver;

  static const double heightMaxFactor = 2.4;
  static const double minThumbnailAspectRatio = 9 / 32;
  static const double maxThumbnailAspectRatio = 32 / 9;

  MosaicSectionLayoutBuilder({
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
    required Duration tileAnimationDelay,
    required this.coverRatioResolver,
  }) : super(tileAnimationDelay: Duration(milliseconds: (tileAnimationDelay.inMilliseconds / columnCount).ceil())) {
    final rowWidth = scrollableWidth - horizontalPadding * 2;
    rowAvailableWidth = (itemCount) => rowWidth - (itemCount - 1) * spacing;
    rowHeightMax = tileWidth * heightMaxFactor;
  }

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

    return MosaicSectionedListLayout<T>(
      sections: sections,
      showHeaders: showHeaders,
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
    final rows = computeMosaicRows(
      section: section,
      availableWidthFor: rowAvailableWidth,
      heightMax: rowHeightMax,
      targetExtent: tileWidth,
      spacing: spacing,
      bottom: bottom,
      coverRatioResolver: (item) => coverRatioResolver(item).clamp(minThumbnailAspectRatio, maxThumbnailAspectRatio),
    );
    final rowCount = rows.length;
    final sectionChildCount = 1 + rowCount;

    final sectionFirstIndex = _currentIndex;
    _currentIndex += sectionChildCount;
    final sectionLastIndex = _currentIndex - 1;

    final sectionMinOffset = _currentOffset;
    _currentOffset += headerExtent + rows.map((v) => v.height).sum - spacing;
    final sectionMaxOffset = _currentOffset;

    return MosaicSectionLayout(
      sectionKey: sectionKey,
      firstIndex: sectionFirstIndex,
      lastIndex: sectionLastIndex,
      minOffset: sectionMinOffset,
      maxOffset: sectionMaxOffset,
      headerExtent: headerExtent,
      rows: rows,
      spacing: spacing,
      builder: (context, listIndex) {
        final textDirection = Directionality.of(context);
        final sectionChildIndex = listIndex - sectionFirstIndex;
        final isHeader = sectionChildIndex == 0;
        final row = isHeader ? rows.first : rows[sectionChildIndex - 1];
        final sectionGridIndex = isHeader ? sectionFirstIndex * columnCount : (sectionChildIndex + 1) * columnCount + row.firstIndex;
        return buildSectionWidget(
          context: context,
          section: section,
          sectionGridIndex: sectionGridIndex,
          sectionChildIndex: sectionChildIndex,
          itemIndexRange: () => isHeader ? const (0, 0) : (row.firstIndex, row.lastIndex + 1),
          sectionKey: sectionKey,
          headerExtent: headerExtent,
          itemSizes: row.itemWidths.map((v) => Size(v, row.height)).toList(),
          animate: animate,
          buildGridRow: (children) {
            return isHeader
                ? const SizedBox()
                : MosaicGridRow(
                    rowLayout: row,
                    spacing: spacing,
                    textDirection: textDirection,
                    children: children,
                  );
          },
        );
      },
    );
  }

  static List<MosaicRowLayout> computeMosaicRows<T>({
    required List<T> section,
    required double Function(int itemCount) availableWidthFor,
    required double heightMax,
    required double targetExtent,
    required double spacing,
    required double bottom,
    required CoverRatioResolver<T> coverRatioResolver,
  }) {
    final rows = <MosaicRowLayout>[];
    final items = <T>[];
    double ratioSum = 0, ratioMin = double.infinity;
    int firstIndex = 0;
    double minOffset = 0;

    void addRow(int i, {required bool complete}) {
      if (items.isEmpty) return;

      final availableWidth = availableWidthFor(items.length);
      var height = availableWidth / ratioSum + spacing;
      if (height > heightMax + precisionErrorTolerance) {
        if (!complete) {
          ratioSum = availableWidth / (heightMax - spacing);
          addRow(i, complete: complete);
        }
        return;
      }

      height += bottom;
      rows.add(MosaicRowLayout(
        firstIndex: firstIndex,
        lastIndex: i - 1,
        minOffset: minOffset,
        height: height,
        itemWidths: items.map((item) => availableWidth * coverRatioResolver(item) / ratioSum).toList(),
      ));
      firstIndex = i;
      minOffset += height;
      ratioMin = double.infinity;
      ratioSum = 0;
      items.clear();
    }

    section.forEachIndexed((i, item) {
      final ratio = coverRatioResolver(item);
      final nextAvailableWidth = availableWidthFor(items.length + 1);
      final nextRatioSum = ratio + ratioSum;
      final nextItemMinWidth = nextAvailableWidth * min(ratio, ratioMin) / nextRatioSum;
      final nextHeight = nextAvailableWidth / nextRatioSum + spacing;
      if (nextItemMinWidth < targetExtent || nextHeight < targetExtent) {
        // add row when appending the next item would make other items too small
        addRow(i, complete: true);
      }
      items.add(item);
      ratioMin = min(ratio, ratioMin);
      ratioSum += ratio;
    });
    if (items.isNotEmpty) {
      // add last row, possibly incomplete
      addRow(section.length, complete: false);
    }

    return rows;
  }
}
