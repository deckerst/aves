import 'dart:async';

import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/scroll_label.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/transition.dart';
import 'package:flutter/widgets.dart';

/*
  adapted from package `draggable_scrollbar` v0.0.4:
  - removed default thumb builders
  - allow any `ScrollView` as child
  - allow any `Widget` as label content
  - moved out constraints responsibility
  - various extent & thumb positioning fixes
  - null safety
  - directionality aware
 */

/// Build the Scroll Thumb and label using the current configuration
typedef ScrollThumbBuilder = Widget Function(
  Color backgroundColor,
  Animation<double> thumbAnimation,
  Animation<double> labelAnimation,
  double height, {
  Widget? labelText,
});

/// Build a Text widget using the current scroll offset
typedef OffsetLabelBuilder = Widget Function(double offsetY);
typedef TextLabelBuilder = Widget Function(String label);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class DraggableScrollbar extends StatefulWidget {
  /// The background color of the label and thumb
  final Color backgroundColor;

  final Map<double, String> Function()? crumbsBuilder;

  final Size scrollThumbSize;

  /// A function that builds a thumb using the current configuration
  final ScrollThumbBuilder scrollThumbBuilder;

  /// The amount of padding that should surround the thumb
  final EdgeInsets padding;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Text widget from the current offset in the BoxScrollView
  final OffsetLabelBuilder labelTextBuilder;

  final TextLabelBuilder crumbTextBuilder;

  /// The ScrollController for the BoxScrollView
  final ScrollController controller;

  final double Function(double scrollOffset, double offsetIncrement)? dragOffsetSnapper;

  /// The view that will be scrolled with the scroll thumb
  final ScrollView child;

  DraggableScrollbar({
    super.key,
    required this.backgroundColor,
    required this.scrollThumbSize,
    required this.scrollThumbBuilder,
    required this.controller,
    this.dragOffsetSnapper,
    this.crumbsBuilder,
    this.padding = EdgeInsets.zero,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 1000),
    required this.labelTextBuilder,
    required this.crumbTextBuilder,
    required this.child,
  }) : assert(child.scrollDirection == Axis.vertical);

  @override
  State<DraggableScrollbar> createState() => _DraggableScrollbarState();

  static const double labelThumbPadding = 16;

  static Widget buildScrollThumbAndLabel({
    required Widget scrollThumb,
    required Color backgroundColor,
    required Animation<double> thumbAnimation,
    required Animation<double> labelAnimation,
    required Widget? labelText,
  }) {
    final scrollThumbAndLabel = labelText == null
        ? scrollThumb
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ScrollLabel(
                animation: labelAnimation,
                backgroundColor: backgroundColor,
                child: labelText,
              ),
              const SizedBox(width: labelThumbPadding),
              scrollThumb,
            ],
          );
    return SlideFadeTransition(
      animation: thumbAnimation,
      child: scrollThumbAndLabel,
    );
  }
}

class _DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  final ValueNotifier<double> _thumbOffsetNotifier = ValueNotifier(0), _viewOffsetNotifier = ValueNotifier(0);
  bool _isDragInProcess = false;
  double _boundlessThumbOffset = 0, _offsetIncrement = 0;
  late Offset _longPressLastGlobalPosition;

  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbAnimation;
  late AnimationController _labelAnimationController;
  late Animation<double> _labelAnimation;
  Timer? _fadeoutTimer;
  Map<double, String>? _percentCrumbs;
  final Map<double, String> _viewportCrumbs = {};

  static const double crumbPadding = 30;
  static const double crumbMinViewportRatio = 4;

  @override
  void initState() {
    super.initState();

    _thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _thumbAnimation = CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    _labelAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _labelAnimation = CurvedAnimation(
      parent: _labelAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didUpdateWidget(covariant DraggableScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.crumbsBuilder != widget.crumbsBuilder) {
      _percentCrumbs = null;
    }
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    _labelAnimationController.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  ScrollController get controller => widget.controller;

  double get scrollBarHeight => context.size!.height - widget.padding.vertical;

  double get thumbMaxScrollExtent => scrollBarHeight - widget.scrollThumbSize.height;

  double get thumbMinScrollExtent => 0.0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScrollNotification(notification);
        return false;
      },
      child: Stack(
        children: [
          RepaintBoundary(
            child: widget.child,
          ),
          if (_isDragInProcess)
            ..._viewportCrumbs.entries.map((kv) {
              final offset = kv.key;
              final label = kv.value;
              return Positioned.directional(
                textDirection: Directionality.of(context),
                top: offset,
                end: DraggableScrollbar.labelThumbPadding + widget.scrollThumbSize.width,
                child: Padding(
                  padding: widget.padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: widget.scrollThumbSize.height),
                    child: Center(
                      child: ScrollLabel(
                        animation: kAlwaysCompleteAnimation,
                        backgroundColor: widget.backgroundColor,
                        child: widget.crumbTextBuilder(label),
                      ),
                    ),
                  ),
                ),
              );
            }),
          // exclude semantics, otherwise this layer will block access to content layers below when using TalkBack
          ExcludeSemantics(
            child: RepaintBoundary(
              child: GestureDetector(
                onLongPressStart: (details) {
                  _longPressLastGlobalPosition = details.globalPosition;
                  _onVerticalDragStart();
                },
                onLongPressMoveUpdate: (details) {
                  final dy = (details.globalPosition - _longPressLastGlobalPosition).dy;
                  _longPressLastGlobalPosition = details.globalPosition;
                  _onVerticalDragUpdate(dy);
                },
                onLongPressEnd: (_) => _onVerticalDragEnd(),
                onVerticalDragStart: (_) => _onVerticalDragStart(),
                onVerticalDragUpdate: (details) => _onVerticalDragUpdate(details.delta.dy),
                onVerticalDragEnd: (_) => _onVerticalDragEnd(),
                child: ValueListenableBuilder<double>(
                  valueListenable: _thumbOffsetNotifier,
                  builder: (context, thumbOffset, child) => Container(
                    alignment: AlignmentDirectional.topEnd,
                    padding: EdgeInsets.only(top: thumbOffset) + widget.padding,
                    child: widget.scrollThumbBuilder(
                      widget.backgroundColor,
                      _thumbAnimation,
                      _labelAnimation,
                      widget.scrollThumbSize.height,
                      labelText: _isDragInProcess
                          ? ValueListenableBuilder<double>(
                              valueListenable: _viewOffsetNotifier,
                              builder: (context, viewOffset, child) => widget.labelTextBuilder(viewOffset + thumbOffset),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onScrollNotification(ScrollNotification notification) {
    final scrollMetrics = notification.metrics;

    // do not update the thumb if we cannot actually scroll
    if (scrollMetrics.minScrollExtent >= scrollMetrics.maxScrollExtent) return;

    _viewOffsetNotifier.value = scrollMetrics.pixels;

    // we update the thumb position from the scrolled offset
    // when the user is not dragging the thumb
    if (!_isDragInProcess) {
      if (notification is ScrollUpdateNotification) {
        final scrollExtent = (scrollMetrics.pixels / scrollMetrics.maxScrollExtent * thumbMaxScrollExtent);
        _thumbOffsetNotifier.value = thumbMaxScrollExtent > thumbMinScrollExtent ? scrollExtent.clamp(thumbMinScrollExtent, thumbMaxScrollExtent) : thumbMinScrollExtent;
      }

      if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
        _showThumb();
        _scheduleFadeout();
      }
    }
  }

  void _onVerticalDragStart() {
    const DraggableScrollbarNotification(DraggableScrollbarEvent.dragStart).dispatch(context);
    _boundlessThumbOffset = _thumbOffsetNotifier.value;
    _offsetIncrement = 1 / thumbMaxScrollExtent * controller.position.maxScrollExtent;
    _labelAnimationController.forward();
    _fadeoutTimer?.cancel();
    _showThumb();
    _updateViewportCrumbs();
    setState(() => _isDragInProcess = true);
  }

  void _onVerticalDragUpdate(double deltaY) {
    _showThumb();
    if (_isDragInProcess) {
      // thumb offset
      _boundlessThumbOffset += deltaY;
      _thumbOffsetNotifier.value = _boundlessThumbOffset.clamp(thumbMinScrollExtent, thumbMaxScrollExtent);

      // scroll offset
      final min = controller.position.minScrollExtent;
      final max = controller.position.maxScrollExtent;
      final scrollOffset = _thumbOffsetNotifier.value / thumbMaxScrollExtent * max;
      controller.jumpTo((widget.dragOffsetSnapper?.call(scrollOffset, _offsetIncrement) ?? scrollOffset).clamp(min, max));
    }
  }

  void _onVerticalDragEnd() {
    const DraggableScrollbarNotification(DraggableScrollbarEvent.dragEnd).dispatch(context);
    _scheduleFadeout();
    setState(() => _isDragInProcess = false);
  }

  void _showThumb() {
    if (_thumbAnimationController.status != AnimationStatus.forward) {
      _thumbAnimationController.forward();
    }
  }

  void _scheduleFadeout() {
    _fadeoutTimer?.cancel();
    _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
      _thumbAnimationController.reverse();
      _labelAnimationController.reverse();
      _fadeoutTimer = null;
    });
  }

  void _updateViewportCrumbs() {
    _viewportCrumbs.clear();
    final crumbsBuilder = widget.crumbsBuilder;
    if (crumbsBuilder != null) {
      final maxOffset = thumbMaxScrollExtent;
      final position = controller.position;
      if (position.maxScrollExtent / position.viewportDimension > crumbMinViewportRatio) {
        double lastLabelOffset = -crumbPadding;
        _percentCrumbs ??= crumbsBuilder();
        _percentCrumbs!.entries.forEach((kv) {
          final percent = kv.key;
          final label = kv.value;
          final labelOffset = percent * maxOffset;
          if (labelOffset >= lastLabelOffset + crumbPadding) {
            lastLabelOffset = labelOffset;
            _viewportCrumbs[labelOffset] = label;
          }
        });
        // hide lonesome crumb, whether it is because of a single section,
        // or because multiple sections collapsed to a single crumb
        if (_viewportCrumbs.length == 1) {
          _viewportCrumbs.clear();
        }
      }
    }
  }
}
