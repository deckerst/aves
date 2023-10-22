import 'package:flutter/widgets.dart';

/// When a `Magnifier` is wrapped in this inherited widget,
/// it will check whether the zoomed content has hit edges,
/// and if so, will let parent gesture detectors win the gesture arena
///
/// Useful when placing Magnifier inside a gesture sensitive context,
/// such as [PageView], [Dismissible], [BottomSheet].
class MagnifierGestureDetectorScope extends InheritedWidget {
  final List<Axis> axis;

  // in [0, 1[
  // 0: most reactive but will not let tap recognizers accept gestures
  // <1: less reactive but gives the most leeway to other recognizers
  // 1: will not be able to compete with a `HorizontalDragGestureRecognizer` up the widget tree
  final double touchSlopFactor;

  // when zoomed in and hitting an edge, allow using a fling gesture to go to the previous/next page,
  // instead of yielding to the outer scrollable right away
  final bool escapeByFling;

  final bool? Function(Offset move)? acceptPointerEvent;

  const MagnifierGestureDetectorScope({
    super.key,
    required this.axis,
    this.touchSlopFactor = .8,
    this.escapeByFling = true,
    this.acceptPointerEvent,
    required super.child,
  });

  static MagnifierGestureDetectorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MagnifierGestureDetectorScope>();
  }

  MagnifierGestureDetectorScope copyWith({
    List<Axis>? axis,
    double? touchSlopFactor,
    bool? Function(Offset move)? acceptPointerEvent,
    required Widget child,
  }) {
    return MagnifierGestureDetectorScope(
      axis: axis ?? this.axis,
      touchSlopFactor: touchSlopFactor ?? this.touchSlopFactor,
      acceptPointerEvent: acceptPointerEvent ?? this.acceptPointerEvent,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(MagnifierGestureDetectorScope oldWidget) {
    return axis != oldWidget.axis || touchSlopFactor != oldWidget.touchSlopFactor || acceptPointerEvent != oldWidget.acceptPointerEvent;
  }
}
