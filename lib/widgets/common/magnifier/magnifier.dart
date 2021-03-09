import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/core.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/material.dart';

/*
  `Magnifier` is derived from `photo_view` package v0.9.2:
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
class Magnifier extends StatelessWidget {
  const Magnifier({
    Key key,
    @required this.controller,
    @required this.childSize,
    this.minScale = const ScaleLevel(factor: .0),
    this.maxScale = const ScaleLevel(factor: double.infinity),
    this.initialScale = const ScaleLevel(ref: ScaleReference.contained),
    this.scaleStateCycle = defaultScaleStateCycle,
    this.applyScale = true,
    this.onTap,
    @required this.child,
  })  : assert(controller != null),
        assert(childSize != null),
        assert(minScale != null),
        assert(maxScale != null),
        assert(initialScale != null),
        assert(scaleStateCycle != null),
        assert(applyScale != null),
        super(key: key);

  final MagnifierController controller;

  // The size of the custom [child]. This value is used to compute the relation between the child and the container's size to calculate the scale value.
  final Size childSize;

  // Defines the minimum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel minScale;

  // Defines the maximum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel maxScale;

  // Defines the size the image will assume when the component is initialized, it is proportional to the original image size.
  final ScaleLevel initialScale;

  final ScaleStateCycle scaleStateCycle;
  final bool applyScale;
  final MagnifierTapCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.setScaleBoundaries(ScaleBoundaries(
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          viewportSize: constraints.biggest,
          childSize: childSize?.isEmpty == false ? childSize : constraints.biggest,
        ));

        return MagnifierCore(
          controller: controller,
          scaleStateCycle: scaleStateCycle,
          onTap: onTap,
          applyScale: applyScale,
          child: child,
        );
      },
    );
  }
}

typedef MagnifierTapCallback = Function(
  BuildContext context,
  TapUpDetails details,
  MagnifierState state,
  Offset childTapPosition,
);
