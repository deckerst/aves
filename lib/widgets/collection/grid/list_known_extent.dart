import 'dart:math' as math;

import 'package:aves/widgets/collection/grid/list_section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverKnownExtentList extends SliverMultiBoxAdaptorWidget {
  final List<SectionLayout> sectionLayouts;

  const SliverKnownExtentList({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.sectionLayouts,
  }) : super(key: key, delegate: delegate);

  @override
  RenderSliverKnownExtentBoxAdaptor createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverKnownExtentBoxAdaptor(childManager: element, sectionLayouts: sectionLayouts);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverKnownExtentBoxAdaptor renderObject) {
    renderObject.sectionLayouts = sectionLayouts;
  }
}

class RenderSliverKnownExtentBoxAdaptor extends RenderSliverMultiBoxAdaptor {
  List<SectionLayout> _sectionLayouts;

  List<SectionLayout> get sectionLayouts => _sectionLayouts;

  set sectionLayouts(List<SectionLayout> value) {
    assert(value != null);
    if (_sectionLayouts == value) return;
    _sectionLayouts = value;
    markNeedsLayout();
  }

  RenderSliverKnownExtentBoxAdaptor({
    @required RenderSliverBoxChildManager childManager,
    @required List<SectionLayout> sectionLayouts,
  })  : _sectionLayouts = sectionLayouts,
        super(childManager: childManager);

  SectionLayout sectionAtIndex(int index) => sectionLayouts.firstWhere((section) => section.hasChild(index), orElse: () => null);

  SectionLayout sectionAtOffset(double scrollOffset) => sectionLayouts.firstWhere((section) => section.hasChildAtOffset(scrollOffset), orElse: () => sectionLayouts.last);

  double indexToLayoutOffset(int index) {
    return (sectionAtIndex(index) ?? sectionLayouts.last).indexToLayoutOffset(index);
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return sectionAtOffset(scrollOffset).getMinChildIndexForScrollOffset(scrollOffset);
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return sectionAtOffset(scrollOffset).getMaxChildIndexForScrollOffset(scrollOffset);
  }

  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    return childManager.estimateMaxScrollOffset(
      constraints,
      firstIndex: firstIndex,
      lastIndex: lastIndex,
      leadingScrollOffset: leadingScrollOffset,
      trailingScrollOffset: trailingScrollOffset,
    );
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
      final trailingGarbage = _calculateTrailingGarbage(targetLastIndex);
      collectGarbage(leadingGarbage, trailingGarbage);
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      if (!addInitialChild(index: firstIndex, layoutOffset: indexToLayoutOffset(firstIndex))) {
        // There are either no children, or we are past the end of all our children.
        // If it is the latter, we will need to find the first available child.
        double max;
        if (childManager.childCount != null) {
          max = computeMaxScrollOffset(constraints);
        } else if (firstIndex <= 0) {
          max = 0.0;
        } else {
          // We will have to find it manually.
          var possibleFirstIndex = firstIndex - 1;
          while (possibleFirstIndex > 0 &&
              !addInitialChild(
                index: possibleFirstIndex,
                layoutOffset: indexToLayoutOffset(possibleFirstIndex),
              )) {
            possibleFirstIndex -= 1;
          }
          max = sectionAtIndex(possibleFirstIndex).indexToLayoutOffset(possibleFirstIndex);
        }
        geometry = SliverGeometry(
          scrollExtent: max,
          maxPaintExtent: max,
        );
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox trailingChildWithLayout;

    for (var index = indexOf(firstChild) - 1; index >= firstIndex; --index) {
      final child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        final layout = sectionAtIndex(index) ?? sectionLayouts.first;
        geometry = SliverGeometry(scrollOffsetCorrection: layout.indexToMaxScrollOffset(index));
        return;
      }
      final childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild.layout(childConstraints);
      final childParentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(firstIndex);
      trailingChildWithLayout = firstChild;
    }

    var estimatedMaxScrollOffset = double.infinity;
    for (var index = indexOf(trailingChildWithLayout) + 1; targetLastIndex == null || index <= targetLastIndex; ++index) {
      var child = childAfter(trailingChildWithLayout);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints, after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          final layout = sectionAtIndex(index) ?? sectionLayouts.last;
          estimatedMaxScrollOffset = layout.indexToMaxScrollOffset(index);
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      assert(child != null);
      final childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset = indexToLayoutOffset(childParentData.index);
    }

    final lastIndex = indexOf(lastChild);
    final leadingScrollOffset = indexToLayoutOffset(firstIndex);
    final trailingScrollOffset = indexToLayoutOffset(lastIndex + 1);

    assert(firstIndex == 0 || childScrollOffset(firstChild) - scrollOffset <= precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild) == firstIndex);
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
      from: leadingScrollOffset,
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
      paintExtent: paintExtent,
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
