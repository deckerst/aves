import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThumbnailScroller extends StatefulWidget {
  final double availableWidth;
  final int entryCount;
  final AvesEntry? Function(int index) entryBuilder;
  final int? initialIndex;
  final void Function(int index) onIndexChange;

  const ThumbnailScroller({
    Key? key,
    required this.availableWidth,
    required this.entryCount,
    required this.entryBuilder,
    required this.initialIndex,
    required this.onIndexChange,
  }) : super(key: key);

  @override
  _ThumbnailScrollerState createState() => _ThumbnailScrollerState();
}

class _ThumbnailScrollerState extends State<ThumbnailScroller> {
  final _cancellableNotifier = ValueNotifier(true);
  late ScrollController _scrollController;
  bool _syncScroll = true;
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier(-1);

  static const double extent = 48;
  static const double separatorWidth = 2;

  int get entryCount => widget.entryCount;

  @override
  void initState() {
    super.initState();
    _registerWidget();
  }

  @override
  void didUpdateWidget(covariant ThumbnailScroller oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex) {
      _unregisterWidget();
      _registerWidget();
    }
  }

  @override
  void dispose() {
    _unregisterWidget();
    super.dispose();
  }

  void _registerWidget() {
    _currentIndexNotifier.value = widget.initialIndex ?? 0;
    final scrollOffset = indexToScrollOffset(_currentIndexNotifier.value);
    _scrollController = ScrollController(initialScrollOffset: scrollOffset);
    _scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget() {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marginWidth = max(0.0, (widget.availableWidth - extent) / 2 - separatorWidth);
    final horizontalMargin = SizedBox(width: marginWidth);
    const separator = SizedBox(width: separatorWidth);

    return GridTheme(
      extent: extent,
      showLocation: false,
      child: SizedBox(
        height: extent,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          // default padding in scroll direction matches `MediaQuery.viewPadding`,
          // but we already accommodate for it, so make sure horizontal padding is 0
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            if (index == 0 || index == entryCount + 1) return horizontalMargin;
            final page = index - 1;
            final pageEntry = widget.entryBuilder(page);
            if (pageEntry == null) return const SizedBox();

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => _goTo(page),
                  child: DecoratedThumbnail(
                    entry: pageEntry,
                    tileExtent: extent,
                    // the retrieval task queue can pile up for thumbnails of heavy pages
                    // (e.g. thumbnails of 15MP HEIF images inside 100MB+ HEIC containers)
                    // so we cancel these requests when possible
                    cancellableNotifier: _cancellableNotifier,
                    selectable: false,
                    highlightable: false,
                    hero: false,
                  ),
                ),
                IgnorePointer(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentIndexNotifier,
                    builder: (context, currentIndex, child) {
                      return AnimatedContainer(
                        color: currentIndex == page ? Colors.transparent : Colors.black45,
                        width: extent,
                        height: extent,
                        duration: Durations.thumbnailScrollerShadeAnimation,
                      );
                    },
                  ),
                )
              ],
            );
          },
          separatorBuilder: (context, index) => separator,
          itemCount: entryCount + 2,
        ),
      ),
    );
  }

  Future<void> _goTo(int index) async {
    _syncScroll = false;
    setCurrentIndex(index);
    await _scrollController.animateTo(
      indexToScrollOffset(index),
      duration: Durations.thumbnailScrollerScrollAnimation,
      curve: Curves.easeOutCubic,
    );
    _syncScroll = true;
  }

  void _onScrollChange() {
    if (_syncScroll) {
      setCurrentIndex(scrollOffsetToIndex(_scrollController.offset));
    }
  }

  void setCurrentIndex(int index) {
    if (_currentIndexNotifier.value == index) return;

    _currentIndexNotifier.value = index;
    widget.onIndexChange(index);
  }

  double indexToScrollOffset(int index) => index * (extent + separatorWidth);

  int scrollOffsetToIndex(double offset) => (offset / (extent + separatorWidth)).round();
}
