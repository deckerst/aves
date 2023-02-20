import 'package:aves_magnifier/src/controller/controller.dart';
import 'package:aves_magnifier/src/controller/state.dart';
import 'package:aves_magnifier/src/core/core.dart';
import 'package:aves_magnifier/src/scale/scale_boundaries.dart';
import 'package:aves_magnifier/src/scale/scale_level.dart';
import 'package:aves_magnifier/src/scale/state.dart';
import 'package:flutter/material.dart';

/*
  adapted from package `photo_view` v0.9.2:
  - removed image related aspects to focus on a general purpose pan/scale viewer (à la `InteractiveViewer`)
  - removed rotation and many customization parameters
  - removed ignorable/ignoring partial notifiers
  - formatted, renamed and reorganized
  - fixed gesture recognizers when used inside a scrollable widget like `PageView`
  - fixed corner hit detection when in containers scrollable in both axes
  - fixed corner hit detection issues due to imprecise double comparisons
  - added single & double tap position feedback
  - fixed focus when scaling by double-tap/pinch
 */
class AvesMagnifier extends StatelessWidget {
  const AvesMagnifier({
    super.key,
    required this.controller,
    required this.childSize,
    this.allowOriginalScaleBeyondRange = true,
    this.minScale = const ScaleLevel(factor: .0),
    this.maxScale = const ScaleLevel(factor: double.infinity),
    this.initialScale = const ScaleLevel(ref: ScaleReference.contained),
    this.scaleStateCycle = defaultScaleStateCycle,
    this.applyScale = true,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onFling,
    this.onTap,
    this.onDoubleTap,
    required this.child,
  });

  final AvesMagnifierController controller;

  // The size of the custom [child]. This value is used to compute the relation between the child and the container's size to calculate the scale value.
  final Size childSize;

  final bool allowOriginalScaleBeyondRange;

  // Defines the minimum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel minScale;

  // Defines the maximum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel maxScale;

  // Defines the size the image will assume when the component is initialized, it is proportional to the original image size.
  final ScaleLevel initialScale;

  final ScaleStateCycle scaleStateCycle;
  final bool applyScale;
  final MagnifierGestureScaleStartCallback? onScaleStart;
  final MagnifierGestureScaleUpdateCallback? onScaleUpdate;
  final MagnifierGestureScaleEndCallback? onScaleEnd;
  final MagnifierGestureFlingCallback? onFling;
  final MagnifierTapCallback? onTap;
  final MagnifierDoubleTapCallback? onDoubleTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.setScaleBoundaries(ScaleBoundaries(
          allowOriginalScaleBeyondRange: allowOriginalScaleBeyondRange,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          viewportSize: constraints.biggest,
          childSize: childSize.isEmpty == false ? childSize : constraints.biggest,
        ));

        return MagnifierCore(
          controller: controller,
          scaleStateCycle: scaleStateCycle,
          applyScale: applyScale,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          onFling: onFling,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: child,
        );
      },
    );
  }
}

typedef MagnifierTapCallback = Function(
  BuildContext context,
  MagnifierState state,
  Alignment alignment,
  Offset childTapPosition,
);
typedef MagnifierDoubleTapCallback = bool Function(Alignment alignment);
typedef MagnifierGestureScaleStartCallback = void Function(ScaleStartDetails details, bool doubleTap, ScaleBoundaries boundaries);
typedef MagnifierGestureScaleUpdateCallback = bool Function(ScaleUpdateDetails details);
typedef MagnifierGestureScaleEndCallback = void Function(ScaleEndDetails details);
typedef MagnifierGestureFlingCallback = void Function(AxisDirection direction);
