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
  final bool? Function(Offset move)? acceptPointerEvent;

  const MagnifierGestureDetectorScope({
    super.key,
    required this.axis,
    this.touchSlopFactor = .8,
    this.acceptPointerEvent,
    required Widget child,
  }) : super(child: child);

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
