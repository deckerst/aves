import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/scale_overlay.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/section_layout_builder.dart';
import 'package:flutter/material.dart';

class MosaicGrid extends StatelessWidget {
  final Rect contentRect;
  final Size tileSize;
  final double spacing;
  final MosaicItemBuilder builder;

  static const _itemRatios = <double>[
    3 / 4,
    16 / 9,
    9 / 16,
    3 / 4,
    4 / 3,
    4 / 3,
    3 / 4,
    4 / 3,
    4 / 3,
    4 / 3,
  ];

  const MosaicGrid({
    super.key,
    required this.contentRect,
    required this.tileSize,
    required this.spacing,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    final targetExtent = tileSize.width;
    final rows = MosaicSectionLayoutBuilder.computeMosaicRows(
      section: List.generate(5, (i) => _itemRatios).expand((v) => v).toList(),
      availableWidthFor: (itemCount) => contentRect.width - (itemCount - 1) * spacing,
      heightMax: targetExtent * MosaicSectionLayoutBuilder.heightMaxFactor,
      targetExtent: targetExtent,
      spacing: spacing,
      bottom: tileSize.height - tileSize.width,
      coverRatioResolver: (item) => item,
    );

    var i = 0;
    var dy = contentRect.top;
    rows.forEach((row) {
      var dx = contentRect.left;
      final itemHeight = row.height - spacing;
      row.itemWidths.forEach((itemWidth) {
        children.add(
          AnimatedPositioned(
            left: dx,
            top: dy,
            width: itemWidth,
            height: itemHeight,
            duration: Durations.scalingGridPositionAnimation,
            child: builder(i, targetExtent),
          ),
        );
        dx += itemWidth + spacing;
        i++;
      });
      dy += row.height;
    });

    return Stack(
      children: children,
    );
  }
}
