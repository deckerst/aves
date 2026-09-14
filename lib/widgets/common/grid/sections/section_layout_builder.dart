import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

typedef TileBuilder<T> = Widget Function(T item, Size tileSize);

abstract class const SectionLayoutBuilder<T>({
  required final Map<SectionKey, List<T>> sections,
  required final bool showHeaders,
  required final double Function(BuildContext context, SectionKey sectionKey) getHeaderExtent,
  required final Widget Function(BuildContext context, SectionKey sectionKey, double headerExtent) buildHeader,
  required final double scrollableWidth,
  required final TileLayout tileLayout,
  required final int columnCount,
  required final double spacing,
  required final double horizontalPadding,
  required final double tileWidth,
  required final double tileHeight,
  required final TileBuilder<T> tileBuilder,
  required final Duration tileAnimationDelay,
}) {
  final double bottom = tileHeight - tileWidth;
  final bool animate = tileAnimationDelay > Duration.zero;

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
      return animate ? buildAnimation(context, sectionGridIndex, header) : header;
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
        children.add(buildAnimation(context, sectionGridIndex + i, item));
      } else {
        children.add(item);
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: buildGridRow(children),
    );
  }

  Widget buildAnimation(BuildContext context, int index, Widget child) {
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
