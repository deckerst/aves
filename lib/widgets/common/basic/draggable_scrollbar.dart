import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
  This is derived from `draggable_scrollbar` package v0.0.4:
  - removed default thumb builders
  - allow any `ScrollView` as child
  - allow any `Widget` as label content
  - moved out constraints responsibility
  - various extent & thumb positioning fixes
 */

/// Build the Scroll Thumb and label using the current configuration
typedef ScrollThumbBuilder = Widget Function(
  Color backgroundColor,
  Animation<double> thumbAnimation,
  Animation<double> labelAnimation,
  double height, {
  Widget labelText,
});

/// Build a Text widget using the current scroll offset
typedef LabelTextBuilder = Widget Function(double offsetY);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class DraggableScrollbar extends StatefulWidget {
  /// The background color of the label and thumb
  final Color backgroundColor;

  /// The height of the scroll thumb
  final double scrollThumbHeight;

  /// A function that builds a thumb using the current configuration
  final ScrollThumbBuilder scrollThumbBuilder;

  /// The amount of padding that should surround the thumb
  final EdgeInsetsGeometry padding;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Text widget from the current offset in the BoxScrollView
  final LabelTextBuilder labelTextBuilder;

  /// The ScrollController for the BoxScrollView
  final ScrollController controller;

  /// The view that will be scrolled with the scroll thumb
  final ScrollView child;

  DraggableScrollbar({
    Key key,
    @required this.backgroundColor,
    @required this.scrollThumbHeight,
    @required this.scrollThumbBuilder,
    @required this.controller,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    @required this.child,
  })  : assert(controller != null),
        assert(scrollThumbBuilder != null),
        assert(child.scrollDirection == Axis.vertical),
        super(key: key);

  @override
  _DraggableScrollbarState createState() => _DraggableScrollbarState();

  static Widget buildScrollThumbAndLabel({
    @required Widget scrollThumb,
    @required Color backgroundColor,
    @required Animation<double> thumbAnimation,
    @required Animation<double> labelAnimation,
    @required Widget labelText,
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
    Key key,
    @required this.child,
    @required this.animation,
    @required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: EdgeInsets.only(right: 12.0),
        child: Material(
          elevation: 4.0,
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: child,
        ),
      ),
    );
  }
}

class _DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  final ValueNotifier<double> _thumbOffsetNotifier = ValueNotifier(0), _viewOffsetNotifier = ValueNotifier(0);
  bool _isDragInProcess = false;

  AnimationController _thumbAnimationController;
  Animation<double> _thumbAnimation;
  AnimationController _labelAnimationController;
  Animation<double> _labelAnimation;
  Timer _fadeoutTimer;

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
  void dispose() {
    _thumbAnimationController.dispose();
    _labelAnimationController.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  ScrollController get controller => widget.controller;

  double get thumbMaxScrollExtent => context.size.height - widget.scrollThumbHeight - (widget.padding?.vertical ?? 0.0);

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
          RepaintBoundary(
            child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: ValueListenableBuilder(
                valueListenable: _thumbOffsetNotifier,
                builder: (context, thumbOffset, child) => Container(
                  alignment: AlignmentDirectional.topEnd,
                  padding: EdgeInsets.only(top: thumbOffset) + widget.padding,
                  child: widget.scrollThumbBuilder(
                    widget.backgroundColor,
                    _thumbAnimation,
                    _labelAnimation,
                    widget.scrollThumbHeight,
                    labelText: (widget.labelTextBuilder != null && _isDragInProcess)
                        ? ValueListenableBuilder(
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
        _thumbOffsetNotifier.value = (scrollMetrics.pixels / scrollMetrics.maxScrollExtent * thumbMaxScrollExtent).clamp(thumbMinScrollExtent, thumbMaxScrollExtent);
      }

      if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
        _showThumb();
        _scheduleFadeout();
      }
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _labelAnimationController.forward();
    _fadeoutTimer?.cancel();
    setState(() => _isDragInProcess = true);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _showThumb();
    if (_isDragInProcess) {
      // thumb offset
      _thumbOffsetNotifier.value = (_thumbOffsetNotifier.value + details.delta.dy).clamp(thumbMinScrollExtent, thumbMaxScrollExtent);

      // scroll offset
      final min = controller.position.minScrollExtent;
      final max = controller.position.maxScrollExtent;
      controller.jumpTo((_thumbOffsetNotifier.value / thumbMaxScrollExtent * max).clamp(min, max));
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
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
}

/// Draws 2 triangles like arrow up and arrow down
class ArrowCustomPainter extends CustomPainter {
  Color color;

  ArrowCustomPainter(this.color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY - 2.0), width, height, true),
      paint,
    );
    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY + 2.0), width, height, false),
      paint,
    );
  }

  static Path _trianglePath(Offset o, double width, double height, bool isUp) {
    return Path()
      ..moveTo(o.dx, o.dy)
      ..lineTo(o.dx + width, o.dy)
      ..lineTo(o.dx + (width / 2), isUp ? o.dy - height : o.dy + height)
      ..close();
  }
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    Key key,
    @required this.animation,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => animation.value == 0.0 ? Container() : child,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0.3, 0.0),
          end: Offset(0.0, 0.0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}
