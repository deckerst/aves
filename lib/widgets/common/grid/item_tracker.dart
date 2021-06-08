import 'dart:async';

import 'package:aves/model/highlight.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin GridItemTrackerMixin<T, U extends StatefulWidget> on State<U> {
  ValueNotifier<double> get appBarHeightNotifier;

  GlobalKey get scrollableKey;

  ScrollController get scrollController;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    final highlightInfo = context.read<HighlightInfo>();
    _subscriptions.add(highlightInfo.eventBus.on<TrackEvent<T>>().listen((e) => _trackItem(
          e.item,
          animate: e.animate,
          highlight: e.highlight,
        )));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  // about scrolling & offset retrieval:
  // `Scrollable.ensureVisible` only works on already rendered objects
  // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
  // `RenderViewport.scrollOffsetOf` is a good alternative
  Future<void> _trackItem(T item, {required bool animate, required Object? highlight}) async {
    final sectionedListLayout = context.read<SectionedListLayout<T>>();
    final tileRect = sectionedListLayout.getTileRect(item);
    if (tileRect == null) return;

    final scrollableContext = scrollableKey.currentContext!;
    final scrollableHeight = (scrollableContext.findRenderObject() as RenderBox).size.height;

    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = appBarHeightNotifier.value;
    final scrollOffset = tileRect.top + (tileRect.height - scrollableHeight) / 2 + appBarHeight;

    if (animate) {
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

    if (highlight != null) {
      context.read<HighlightInfo>().set(highlight);
    }
  }
}
