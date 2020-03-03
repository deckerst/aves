import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class SliverTransitionGridDelegateWithCrossAxisCount extends SliverGridDelegate {
  const SliverTransitionGridDelegateWithCrossAxisCount({
    @required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);

  /// The number of children in the cross axis.
  final double crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final t = crossAxisCount - crossAxisCount.truncateToDouble();
    return SliverTransitionGridTileLayout(
      current: _buildSettings(constraints, crossAxisCount),
      floor: t != 0 ? _buildSettings(constraints, crossAxisCount.floorToDouble()) : null,
      ceil: t != 0 ? _buildSettings(constraints, crossAxisCount.ceilToDouble()) : null,
      t: t,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  SliverTransitionGridTileLayoutSettings _buildSettings(SliverConstraints constraints, double crossAxisCount) {
    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    final current = SliverTransitionGridTileLayoutSettings(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
    );
    return current;
  }

  @override
  bool shouldRelayout(SliverTransitionGridDelegateWithCrossAxisCount oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount || oldDelegate.mainAxisSpacing != mainAxisSpacing || oldDelegate.crossAxisSpacing != crossAxisSpacing || oldDelegate.childAspectRatio != childAspectRatio;
  }
}

class SliverTransitionGridTileLayoutSettings {
  final double crossAxisCount;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the main axis.
  final double mainAxisStride;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  const SliverTransitionGridTileLayoutSettings({
    @required this.crossAxisCount,
    @required this.mainAxisStride,
    @required this.crossAxisStride,
    @required this.childMainAxisExtent,
    @required this.childCrossAxisExtent,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisStride != null && mainAxisStride >= 0),
        assert(crossAxisStride != null && crossAxisStride >= 0),
        assert(childMainAxisExtent != null && childMainAxisExtent >= 0),
        assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0);
}

class SliverTransitionGridTileLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative. The
  /// `crossAxisCount` argument must be greater than zero.
  const SliverTransitionGridTileLayout({
    @required this.current,
    this.floor,
    this.ceil,
    this.t = 0,
    @required this.reverseCrossAxis,
  }) : assert(reverseCrossAxis != null);

  final SliverTransitionGridTileLayoutSettings current, floor, ceil;
  final double t;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final settings = t == 0 ? current : floor;
    final index = settings.mainAxisStride > 0.0 ? (settings.crossAxisCount * (scrollOffset ~/ settings.mainAxisStride)).floor() : 0;
    return index;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final settings = t == 0 ? current : floor;
    if (settings.mainAxisStride > 0.0) {
      final int mainAxisCount = (scrollOffset / settings.mainAxisStride).ceil();
      final index = math.max(0, settings.crossAxisCount * mainAxisCount - 1).ceil();
      return index;
    }
    return 0;
  }

  double _getScrollOffset(int index, SliverTransitionGridTileLayoutSettings settings) {
    return (index ~/ settings.crossAxisCount) * settings.mainAxisStride;
  }

  double _getCrossAxisOffset(int index, SliverTransitionGridTileLayoutSettings settings) {
    final double crossAxisStart = (index % settings.crossAxisCount) * settings.crossAxisStride;
    if (reverseCrossAxis) {
      return settings.crossAxisCount * settings.crossAxisStride - crossAxisStart - settings.childCrossAxisExtent - (settings.crossAxisStride - settings.childCrossAxisExtent);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    return SliverGridGeometry(
      scrollOffset: t == 0 ? _getScrollOffset(index, current) : lerpDouble(_getScrollOffset(index, floor), _getScrollOffset(index, ceil), t),
      crossAxisOffset: t == 0 ? _getCrossAxisOffset(index, current) : lerpDouble(_getCrossAxisOffset(index, floor), _getCrossAxisOffset(index, ceil), t),
      mainAxisExtent: current.childMainAxisExtent,
      crossAxisExtent: current.childCrossAxisExtent,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount != null);

    if (t != 0) {
      final index = childCount - 1;
      var maxScrollOffset = lerpDouble(_getScrollOffset(index, floor), _getScrollOffset(index, ceil), t) + current.mainAxisStride;
      return maxScrollOffset;
    }

    final int mainAxisCount = ((childCount - 1) ~/ current.crossAxisCount) + 1;
    final double mainAxisSpacing = current.mainAxisStride - current.childMainAxisExtent;
    final maxScrollOffset = current.mainAxisStride * mainAxisCount - mainAxisSpacing;
    return maxScrollOffset;
  }
}
