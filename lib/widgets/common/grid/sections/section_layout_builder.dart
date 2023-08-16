import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

typedef TileBuilder<T> = Widget Function(T item, Size tileSize);

abstract class SectionLayoutBuilder<T> {
  final Map<SectionKey, List<T>> sections;
  final bool showHeaders;
  final double Function(BuildContext context, SectionKey sectionKey) getHeaderExtent;
  final Widget Function(BuildContext context, SectionKey sectionKey, double headerExtent) buildHeader;
  final double scrollableWidth;
  final TileLayout tileLayout;
  final int columnCount;
  final double spacing, horizontalPadding, tileWidth, tileHeight, bottom;
  final TileBuilder<T> tileBuilder;
  final Duration tileAnimationDelay;
  final bool animate;

  const SectionLayoutBuilder({
    required this.sections,
    required this.showHeaders,
    required this.getHeaderExtent,
    required this.buildHeader,
    required this.scrollableWidth,
    required this.tileLayout,
    required this.columnCount,
    required this.spacing,
    required this.horizontalPadding,
    required this.tileWidth,
    required this.tileHeight,
    required this.tileBuilder,
    required this.tileAnimationDelay,
  })  : animate = tileAnimationDelay > Duration.zero,
        bottom = tileHeight - tileWidth;

  SectionedListLayout<T> updateLayouts(BuildContext context);

  SectionLayout buildSectionLayout({
    required double headerExtent,
    required SectionKey sectionKey,
    required List<T> section,
    required bool animate,
  });

  Widget buildSectionWidget({
    required BuildContext context,
    required List<T> section,
    required int sectionGridIndex,
    required int sectionChildIndex,
    required (int, int) Function() itemIndexRange,
    required SectionKey sectionKey,
    required double headerExtent,
    required List<Size> itemSizes,
    required bool animate,
    required Widget Function(List<Widget> children) buildGridRow,
  }) {
    if (sectionChildIndex == 0) {
      final header = headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : const SizedBox();
      return animate ? _buildAnimation(context, sectionGridIndex, header) : header;
    }

    final sectionItemCount = section.length;
    final itemMinMax = itemIndexRange();
    final minItemIndex = itemMinMax.$1.clamp(0, sectionItemCount);
    final maxItemIndex = itemMinMax.$2.clamp(0, sectionItemCount);
    final childrenCount = maxItemIndex - minItemIndex;
    final children = <Widget>[];
    for (var i = 0; i < childrenCount; i++) {
      final item = RepaintBoundary(
        child: tileBuilder(section[minItemIndex + i], itemSizes[i]),
      );
      if (animate) {
        children.add(_buildAnimation(context, sectionGridIndex + i, item));
      } else {
        children.add(item);
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: buildGridRow(children),
    );
  }

  Widget _buildAnimation(BuildContext context, int index, Widget child) {
    final durations = context.watch<DurationsData>();
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: tileLayout == TileLayout.mosaic ? 1 : columnCount,
      duration: durations.staggeredAnimation,
      delay: tileAnimationDelay,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
