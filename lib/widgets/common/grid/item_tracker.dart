import 'dart:async';
import 'dart:math';

import 'package:aves/model/highlight.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridItemTracker<T> extends StatefulWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final TileLayout tileLayout;
  final ScrollController scrollController;
  final Widget child;

  const GridItemTracker({
    super.key,
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.tileLayout,
    required this.scrollController,
    required this.child,
  });

  @override
  State<GridItemTracker<T>> createState() => _GridItemTrackerState<T>();
}

class _GridItemTrackerState<T> extends State<GridItemTracker<T>> with WidgetsBindingObserver {
  ValueNotifier<double> get appBarHeightNotifier => widget.appBarHeightNotifier;

  ScrollController get scrollController => widget.scrollController;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Size get scrollableSize {
    final scrollableContext = widget.scrollableKey.currentContext!;
    return (scrollableContext.findRenderObject() as RenderBox).size;
  }

  final Set<StreamSubscription> _subscriptions = {};

  // grid section metrics before the app is laid out with the new orientation
  late SectionedListLayout<T> _lastSectionedListLayout;
  late Size _lastScrollableSize;
  Orientation _lastOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();
    final highlightInfo = context.read<HighlightInfo>();
    _subscriptions.add(highlightInfo.eventBus.on<TrackEvent<T>>().listen(_trackItem));
    WidgetsBinding.instance.addObserver(this);
    _saveLayoutMetrics();
  }

  @override
  void didUpdateWidget(covariant GridItemTracker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tileLayout != widget.tileLayout) {
      _onLayoutChanged();
    }
    _saveLayoutMetrics();
  }

  @override
  void didChangeMetrics() {
    // the order of `WidgetsBindingObserver` metrics change notification is unreliable
    // w.r.t. the `View` update, and consequentially to this widget update:
    // `WidgetsBindingObserver` is notified mostly before, sometimes after, the widget update
    final size = View.of(context).physicalSize;
    final orientation = size.width > size.height ? Orientation.landscape : Orientation.portrait;
    if (_lastOrientation != orientation) {
      _lastOrientation = orientation;
      _onLayoutChanged();
      _saveLayoutMetrics();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  // about scrolling & offset retrieval:
  // `Scrollable.ensureVisible` only works on already rendered objects
  // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
  // `RenderViewport.scrollOffsetOf` is a good alternative
  Future<void> _trackItem(TrackEvent event) async {
    final sectionedListLayout = context.read<SectionedListLayout<T>>();
    final tileRect = sectionedListLayout.getTileRect(event.item);
    if (tileRect == null) return;

    final viewportRect = Offset(0, scrollController.offset) & scrollableSize;
    final itemVisibility = max(0, tileRect.intersect(viewportRect).height) / tileRect.height;
    if (!event.predicate(itemVisibility)) return;

    double scrollOffset = tileRect.top + (tileRect.height - scrollableSize.height) * ((event.alignment.y + 1) / 2);
    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    scrollOffset += appBarHeightNotifier.value;
    scrollOffset = scrollOffset.clamp(0, scrollController.position.maxScrollExtent);

    if (scrollOffset > 0) {
      if (event.animate) {
        await scrollController.animateTo(
          scrollOffset,
          duration: Duration(milliseconds: (scrollOffset / 2).round().clamp(ADurations.highlightScrollAnimationMinMillis, ADurations.highlightScrollAnimationMaxMillis)),
          curve: Curves.easeInOutCubic,
        );
      } else {
        scrollController.jumpTo(scrollOffset);
        await Future.delayed(ADurations.highlightJumpDelay);
      }
    }

    final highlightItem = event.highlightItem;
    if (highlightItem != null) {
      context.read<HighlightInfo>().set(highlightItem);
    }
  }

  Future<void> _saveLayoutMetrics() async {
    // use a delay to obtain current layout metrics
    // so that we can handle window orientation change with the previous metrics,
    // regardless of the `View`/`WidgetsBindingObserver` order uncertainty
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _lastSectionedListLayout = context.read<SectionedListLayout<T>>();
    _lastScrollableSize = scrollableSize;
  }

  void _onLayoutChanged() {
    if (scrollController.positions.length != 1) return;

    // do not track when view shows top edge
    if (scrollController.offset == 0) return;

    final layout = _lastSectionedListLayout;
    final halfSize = _lastScrollableSize / 2;
    final center = Offset(
      halfSize.width,
      halfSize.height + scrollController.offset - appBarHeightNotifier.value,
    );
    var pivotItem = layout.getItemAt(center) ?? layout.getItemAt(Offset(0, center.dy));
    if (pivotItem == null) {
      final pivotSectionKey = layout.getSectionAt(center.dy)?.sectionKey;
      if (pivotSectionKey != null) {
        pivotItem = layout.sections[pivotSectionKey]?.firstOrNull;
      }
    }

    if (pivotItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HighlightInfo>().trackItem(pivotItem, animate: false);
      });
    }
  }
}
