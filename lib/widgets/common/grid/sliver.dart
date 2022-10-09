import 'dart:math' as math;

import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// Use a `SliverList` instead of multiple `SliverGrid` because having one `SliverGrid` per section does not scale up.
// With the multiple `SliverGrid` solution, thumbnails at the beginning of each sections are built even though they are offscreen
// because of `RenderSliverMultiBoxAdaptor.addInitialChild` called by `RenderSliverGrid.performLayout` (line 591), as of Flutter v3.3.3.
// cf https://github.com/flutter/flutter/issues/49027
// adapted from Flutter `RenderSliverFixedExtentBoxAdaptor` in `/rendering/sliver_fixed_extent_list.dart`
class SectionedListSliver<T> extends StatelessWidget {
  const SectionedListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionLayouts = context.watch<SectionedListLayout<T>>().sectionLayouts;
    final childCount = sectionLayouts.isEmpty ? 0 : sectionLayouts.last.lastIndex + 1;
    return _SliverKnownExtentList(
      sectionLayouts: sectionLayouts,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= childCount) return null;
          final sectionLayout = sectionLayouts.firstWhereOrNull((section) => section.hasChild(index));
          return sectionLayout?.builder(context, index) ?? const SizedBox();
        },
        childCount: childCount,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      ),
    );
  }
}

class _SliverKnownExtentList extends SliverMultiBoxAdaptorWidget {
  final List<SectionLayout> sectionLayouts;

  const _SliverKnownExtentList({
    required SliverChildDelegate delegate,
    required this.sectionLayouts,
  }) : super(delegate: delegate);

  @override
  _RenderSliverKnownExtentBoxAdaptor createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return _RenderSliverKnownExtentBoxAdaptor(childManager: element, sectionLayouts: sectionLayouts);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSliverKnownExtentBoxAdaptor renderObject) {
    renderObject.sectionLayouts = sectionLayouts;
  }
}

class _RenderSliverKnownExtentBoxAdaptor extends RenderSliverMultiBoxAdaptor {
  List<SectionLayout> _sectionLayouts;

  List<SectionLayout> get sectionLayouts => _sectionLayouts;

  set sectionLayouts(List<SectionLayout> value) {
    if (_sectionLayouts == value) return;
    _sectionLayouts = value;
    markNeedsLayout();
  }

  _RenderSliverKnownExtentBoxAdaptor({
    required RenderSliverBoxChildManager childManager,
    required List<SectionLayout> sectionLayouts,
  })  : _sectionLayouts = sectionLayouts,
        super(childManager: childManager);

  SectionLayout? sectionAtIndex(int index) => sectionLayouts.firstWhereOrNull((section) => section.hasChild(index));

  SectionLayout? sectionAtOffset(double scrollOffset) => sectionLayouts.firstWhereOrNull((section) => section.hasChildAtOffset(scrollOffset)) ?? sectionLayouts.lastOrNull;

  double indexToLayoutOffset(int index) {
    return (sectionAtIndex(index) ?? sectionLayouts.lastOrNull)?.indexToLayoutOffset(index) ?? 0;
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return sectionAtOffset(scrollOffset)?.getMinChildIndexForScrollOffset(scrollOffset) ?? 0;
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return sectionAtOffset(scrollOffset)?.getMaxChildIndexForScrollOffset(scrollOffset) ?? 0;
  }

  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    // default implementation is an estimation via `childManager.estimateMaxScrollOffset()`
    // but we have the accurate offset via pre-computed section layouts
    return _sectionLayouts.last.maxOffset;
  }

  double computeMaxScrollOffset(SliverConstraints constraints) {
    return sectionLayouts.last.maxOffset;
  }

  int _calculateLeadingGarbage(int firstIndex) {
    var walker = firstChild;
    var leadingGarbage = 0;
    while (walker != null && indexOf(walker) < firstIndex) {
      leadingGarbage += 1;
      walker = childAfter(walker);
    }
    return leadingGarbage;
  }

  int _calculateTrailingGarbage(int targetLastIndex) {
    var walker = lastChild;
    var trailingGarbage = 0;
    while (walker != null && indexOf(walker) > targetLastIndex) {
      trailingGarbage += 1;
      walker = childBefore(walker);
    }
    return trailingGarbage;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final targetEndScrollOffset = scrollOffset + remainingExtent;

    final childConstraints = constraints.asBoxConstraints();

    final firstIndex = getMinChildIndexForScrollOffset(scrollOffset);
    final targetLastIndex = targetEndScrollOffset.isFinite ? getMaxChildIndexForScrollOffset(targetEndScrollOffset) : null;

    if (firstChild != null) {
      final leadingGarbage = _calculateLeadingGarbage(firstIndex);
      final trailingGarbage = targetLastIndex != null ? _calculateTrailingGarbage(targetLastIndex) : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      if (!addInitialChild(index: firstIndex, layoutOffset: indexToLayoutOffset(firstIndex))) {
        // There are either no children, or we are past the end of all our children.
        double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints);
        }
        geometry = SliverGeometry(
          scrollExtent: max,
          maxPaintExtent: max,
        );
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? trailingChildWithLayout;

    for (var index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        final layout = sectionAtIndex(index) ?? sectionLayouts.first;
        geometry = SliverGeometry(scrollOffsetCorrection: layout.indexToLayoutOffset(index));
        return;
      }
      final childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(childConstraints);
      final childParentData = firstChild!.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(firstIndex);
      trailingChildWithLayout = firstChild;
    }

    var estimatedMaxScrollOffset = double.infinity;
    for (var index = indexOf(trailingChildWithLayout!) + 1; targetLastIndex == null || index <= targetLastIndex; ++index) {
      var child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints, after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          final layout = sectionAtIndex(index) ?? sectionLayouts.last;
          estimatedMaxScrollOffset = layout.maxOffset;
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      final childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset = indexToLayoutOffset(childParentData.index!);
    }

    final lastIndex = indexOf(lastChild!);
    final leadingScrollOffset = indexToLayoutOffset(firstIndex);
    final trailingScrollOffset = indexToLayoutOffset(lastIndex + 1);

    assert(firstIndex == 0 || childScrollOffset(firstChild!)! - scrollOffset <= precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    final paintExtent = calculatePaintOffset(
      constraints,
      from: math.min(constraints.scrollOffset, leadingScrollOffset),
      to: trailingScrollOffset,
    );

    final cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final targetEndScrollOffsetForPaint = constraints.scrollOffset + constraints.remainingPaintExtent;
    final targetLastIndexForPaint = targetEndScrollOffsetForPaint.isFinite ? getMaxChildIndexForScrollOffset(targetEndScrollOffsetForPaint) : null;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: math.min(paintExtent, estimatedMaxScrollOffset),
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: (targetLastIndexForPaint != null && lastIndex >= targetLastIndexForPaint) || constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset) childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }
}
