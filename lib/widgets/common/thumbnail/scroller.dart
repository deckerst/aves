import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/behaviour/known_extent_scroll_physics.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:flutter/material.dart';

class ThumbnailScroller extends StatefulWidget {
  final double availableWidth;
  final int entryCount;
  final AvesEntry? Function(int index) entryBuilder;
  final ValueNotifier<int?> indexNotifier;
  final void Function(int index)? onTap;
  final Object? Function(AvesEntry entry)? heroTagger;
  final bool highlightable, showLocation;

  const ThumbnailScroller({
    Key? key,
    required this.availableWidth,
    required this.entryCount,
    required this.entryBuilder,
    required this.indexNotifier,
    this.onTap,
    this.heroTagger,
    this.highlightable = false,
    this.showLocation = true,
  }) : super(key: key);

  @override
  _ThumbnailScrollerState createState() => _ThumbnailScrollerState();
}

class _ThumbnailScrollerState extends State<ThumbnailScroller> {
  final _cancellableNotifier = ValueNotifier(true);
  late ScrollController _scrollController;
  bool _isAnimating = false, _isScrolling = false;

  static const double thumbnailExtent = 48;
  static const double separatorWidth = 2;
  static const double itemExtent = thumbnailExtent + separatorWidth;

  int get entryCount => widget.entryCount;

  ValueNotifier<int?> get indexNotifier => widget.indexNotifier;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ThumbnailScroller oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.indexNotifier != widget.indexNotifier) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(ThumbnailScroller widget) {
    final scrollOffset = indexToScrollOffset(indexNotifier.value ?? 0);
    _scrollController = ScrollController(initialScrollOffset: scrollOffset);
    _scrollController.addListener(_onScrollChange);
    widget.indexNotifier.addListener(_onIndexChange);
  }

  void _unregisterWidget(ThumbnailScroller widget) {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
    widget.indexNotifier.removeListener(_onIndexChange);
  }

  @override
  Widget build(BuildContext context) {
    final marginWidth = max(0.0, (widget.availableWidth - thumbnailExtent) / 2 - separatorWidth);
    final padding = EdgeInsets.only(left: marginWidth + separatorWidth, right: marginWidth);

    return GridTheme(
      extent: thumbnailExtent,
      showLocation: widget.showLocation && settings.showThumbnailLocation,
      showTrash: false,
      child: SizedBox(
        height: thumbnailExtent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          // as of Flutter v2.10.2, `FixedExtentScrollController` can only be used with `ListWheelScrollView`
          // and `FixedExtentScrollPhysics` can only be used with Scrollables that uses the `FixedExtentScrollController`
          // so we use `KnownExtentScrollPhysics`, adapted from `FixedExtentScrollPhysics` without the constraints
          physics: KnownExtentScrollPhysics(
            indexToScrollOffset: indexToScrollOffset,
            scrollOffsetToIndex: scrollOffsetToIndex,
          ),
          padding: padding,
          itemExtent: itemExtent,
          itemBuilder: (context, index) => _buildThumbnail(index),
          itemCount: entryCount,
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final pageEntry = widget.entryBuilder(index);
    if (pageEntry == null) return const SizedBox();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            indexNotifier.value = index;
            widget.onTap?.call(index);
          },
          child: DecoratedThumbnail(
            entry: pageEntry,
            tileExtent: thumbnailExtent,
            // the retrieval task queue can pile up for thumbnails of heavy pages
            // (e.g. thumbnails of 15MP HEIF images inside 100MB+ HEIC containers)
            // so we cancel these requests when possible
            cancellableNotifier: _cancellableNotifier,
            selectable: false,
            highlightable: widget.highlightable,
            heroTagger: () => widget.heroTagger?.call(pageEntry),
          ),
        ),
        IgnorePointer(
          child: ValueListenableBuilder<int?>(
            valueListenable: indexNotifier,
            builder: (context, currentIndex, child) {
              return AnimatedContainer(
                color: currentIndex == index ? Colors.transparent : Colors.black45,
                width: thumbnailExtent,
                height: thumbnailExtent,
                duration: Durations.thumbnailScrollerShadeAnimation,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _goTo(int index) async {
    final targetOffset = indexToScrollOffset(index);
    final offsetDelta = (targetOffset - _scrollController.offset).abs();

    if (offsetDelta > widget.availableWidth * 2) {
      _scrollController.jumpTo(targetOffset);
    } else {
      _isAnimating = true;
      await _scrollController.animateTo(
        targetOffset,
        duration: Durations.thumbnailScrollerScrollAnimation,
        curve: Curves.easeOutCubic,
      );
      _isAnimating = false;
    }
  }

  void _onScrollChange() {
    if (!_isAnimating) {
      final index = scrollOffsetToIndex(_scrollController.offset);
      if (indexNotifier.value != index) {
        _isScrolling = true;
        indexNotifier.value = index;
      }
    }
  }

  void _onIndexChange() {
    if (!_isScrolling && !_isAnimating) {
      final index = indexNotifier.value;
      if (index != null) {
        _goTo(index);
      }
    }
    _isScrolling = false;
  }

  double indexToScrollOffset(int index) => index * itemExtent;

  int scrollOffsetToIndex(double offset) => (offset / itemExtent).round();
}
