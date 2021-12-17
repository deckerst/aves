import 'dart:async';
import 'dart:math';

import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
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
    Key? key,
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.tileLayout,
    required this.scrollController,
    required this.child,
  }) : super(key: key);

  @override
  _GridItemTrackerState createState() => _GridItemTrackerState<T>();
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

  Orientation get _windowOrientation {
    final size = WidgetsBinding.instance!.window.physicalSize;
    return size.width > size.height ? Orientation.landscape : Orientation.portrait;
  }

  final List<StreamSubscription> _subscriptions = [];

  // grid section metrics before the app is laid out with the new orientation
  late SectionedListLayout<T> _lastSectionedListLayout;
  late Size _lastScrollableSize;
  late Orientation _lastOrientation;

  @override
  void initState() {
    super.initState();
    final highlightInfo = context.read<HighlightInfo>();
    _subscriptions.add(highlightInfo.eventBus.on<TrackEvent<T>>().listen(_trackItem));
    _lastOrientation = _windowOrientation;
    WidgetsBinding.instance!.addObserver(this);
    _saveLayoutMetrics();
  }

  @override
  void didUpdateWidget(covariant GridItemTracker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tileLayout != widget.tileLayout) {
      _onLayoutChange();
    }
    _saveLayoutMetrics();
  }

  @override
  void didChangeMetrics() {
    // the order of `WidgetsBindingObserver` metrics change notification is unreliable
    // w.r.t. the `MediaQuery` update, and consequentially to this widget update:
    // `WidgetsBindingObserver` is notified mostly before, sometimes after, the widget update
    final orientation = _windowOrientation;
    if (_lastOrientation != orientation) {
      _lastOrientation = orientation;
      _onLayoutChange();
      _saveLayoutMetrics();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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

    final viewportRect = Rect.fromLTWH(0, scrollController.offset, scrollableSize.width, scrollableSize.height);
    final itemVisibility = max(0, tileRect.intersect(viewportRect).height) / tileRect.height;
    if (!event.predicate(itemVisibility)) return;

    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = appBarHeightNotifier.value;
    final scrollOffset = appBarHeight + tileRect.top + (tileRect.height - scrollableSize.height) * ((event.alignment.y + 1) / 2);

    if (event.animate) {
      if (scrollOffset > 0) {
        await scrollController.animateTo(
          scrollOffset,
          duration: Duration(milliseconds: (scrollOffset / 2).round().clamp(Durations.highlightScrollAnimationMinMillis, Durations.highlightScrollAnimationMaxMillis)),
          curve: Curves.easeInOutCubic,
        );
      }
    } else {
      final maxScrollExtent = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(scrollOffset.clamp(.0, maxScrollExtent));
      await Future.delayed(Durations.highlightJumpDelay);
    }

    final highlightItem = event.highlightItem;
    if (highlightItem != null) {
      context.read<HighlightInfo>().set(highlightItem);
    }
  }

  Future<void> _saveLayoutMetrics() async {
    // use a delay to obtain current layout metrics
    // so that we can handle window orientation change with the previous metrics,
    // regardless of the `MediaQuery`/`WidgetsBindingObserver` order uncertainty
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _lastSectionedListLayout = context.read<SectionedListLayout<T>>();
      _lastScrollableSize = scrollableSize;
    }
  }

  void _onLayoutChange() {
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
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        context.read<HighlightInfo>().trackItem(pivotItem, animate: false);
      });
    }
  }
}
