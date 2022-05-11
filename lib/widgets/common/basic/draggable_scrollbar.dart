import 'dart:async';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

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

  /// The view that will be scrolled with the scroll thumb
  final ScrollView child;

  DraggableScrollbar({
    Key? key,
    required this.backgroundColor,
    required this.scrollThumbSize,
    required this.scrollThumbBuilder,
    required this.controller,
    this.crumbsBuilder,
    this.padding = EdgeInsets.zero,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 1000),
    required this.labelTextBuilder,
    required this.crumbTextBuilder,
    required this.child,
  })  : assert(child.scrollDirection == Axis.vertical),
        super(key: key);

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

class ScrollLabel extends StatelessWidget {
  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  const ScrollLabel({
    Key? key,
    required this.child,
    required this.animation,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: const EdgeInsetsDirectional.only(end: 12.0),
        child: Material(
          elevation: 4.0,
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: child,
        ),
      ),
    );
  }
}

class _DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  final ValueNotifier<double> _thumbOffsetNotifier = ValueNotifier(0), _viewOffsetNotifier = ValueNotifier(0);
  bool _isDragInProcess = false;
  late Offset _longPressLastGlobalPosition;

  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbAnimation;
  late AnimationController _labelAnimationController;
  late Animation<double> _labelAnimation;
  Timer? _fadeoutTimer;
  Map<double, String>? _modelCrumbs;
  final List<_Crumb> _viewportCrumbs = [];

  static const crumbPadding = 30.0;
  static const crumbOffsetRatioThreshold = 10;

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
      _modelCrumbs = null;
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
            ..._viewportCrumbs.map((crumb) {
              return Positioned.directional(
                textDirection: Directionality.of(context),
                top: crumb.labelOffset,
                end: DraggableScrollbar.labelThumbPadding + widget.scrollThumbSize.width,
                child: Padding(
                  padding: widget.padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: widget.scrollThumbSize.height),
                    child: Center(
                      child: ScrollLabel(
                        animation: kAlwaysCompleteAnimation,
                        backgroundColor: widget.backgroundColor,
                        child: widget.crumbTextBuilder(crumb.label),
                      ),
                    ),
                  ),
                ),
              );
            }),
          RepaintBoundary(
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
    const DraggableScrollBarNotification(DraggableScrollBarEvent.dragStart).dispatch(context);
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
      _thumbOffsetNotifier.value = (_thumbOffsetNotifier.value + deltaY).clamp(thumbMinScrollExtent, thumbMaxScrollExtent);

      // scroll offset
      final min = controller.position.minScrollExtent;
      final max = controller.position.maxScrollExtent;
      controller.jumpTo((_thumbOffsetNotifier.value / thumbMaxScrollExtent * max).clamp(min, max));
    }
  }

  void _onVerticalDragEnd() {
    const DraggableScrollBarNotification(DraggableScrollBarEvent.dragEnd).dispatch(context);
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
      final position = controller.position;
      final contentHeight = position.maxScrollExtent + thumbMaxScrollExtent + position.viewportDimension;
      final ratio = contentHeight / scrollBarHeight;
      if (ratio > crumbOffsetRatioThreshold) {
        final maxLabelOffset = scrollBarHeight - widget.scrollThumbSize.height;
        double lastLabelOffset = -crumbPadding;
        _modelCrumbs ??= crumbsBuilder();
        _modelCrumbs!.entries.forEach((kv) {
          final viewOffset = kv.key;
          final label = kv.value;
          final labelOffset = (viewOffset / ratio).roundToDouble();
          if (labelOffset >= lastLabelOffset + crumbPadding && labelOffset < maxLabelOffset) {
            lastLabelOffset = labelOffset;
            _viewportCrumbs.add(_Crumb(
              viewOffset: viewOffset,
              labelOffset: labelOffset,
              label: label,
            ));
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

class _Crumb {
  final double viewOffset, labelOffset;
  final String label;

  const _Crumb({
    required this.viewOffset,
    required this.labelOffset,
    required this.label,
  });
}

///This cut 2 lines in arrow shape
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();

    const arrowWidth = 8.0;
    final startPointX = (size.width - arrowWidth) / 2;
    var startPointY = size.height / 2 - arrowWidth / 2;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2);
    path.lineTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth, startPointY + 1.0);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2 + 1.0);
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2 - 1.0);
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => animation.value == 0.0 ? Container() : child!,
      child: SlideTransition(
        position: Tween(
          begin: Offset((context.isRtl ? -1 : 1) * .3, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}

@immutable
class DraggableScrollBarNotification extends Notification {
  final DraggableScrollBarEvent event;

  const DraggableScrollBarNotification(this.event);
}

enum DraggableScrollBarEvent { dragStart, dragEnd }
