import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/core/core.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/scalestate_controller.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/material.dart';

/// `Magnifier` is derived from `photo_view` package v0.9.2:
/// - removed image related aspects to focus on a general purpose pan/scale viewer (à la `InteractiveViewer`)
/// - removed rotation and many customization parameters
/// - removed ignorable/ignoring partial notifiers
/// - formatted, renamed and reorganized
/// - fixed gesture recognizers when used inside a scrollable widget like `PageView`
/// - fixed corner hit detection when in containers scrollable in both axes
/// - fixed corner hit detection issues due to imprecise double comparisons
/// - added single & double tap position feedback
/// - fixed focusing on tap position when scaling by double tap
class Magnifier extends StatefulWidget {
  const Magnifier({
    Key key,
    @required this.child,
    this.childSize,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.scaleStateCycle,
    this.onTap,
    this.gestureDetectorBehavior,
    this.applyScale,
  }) : super(key: key);

  final Widget child;

  /// The size of the custom [child]. This value is used to compute the relation between the child and the container's size to calculate the scale value.
  final Size childSize;

  /// Defines the maximum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it is proportional to the original image size.
  final ScaleLevel minScale;

  /// Defines the size the image will assume when the component is initialized, it is proportional to the original image size.
  final ScaleLevel initialScale;

  final MagnifierController controller;
  final MagnifierScaleStateController scaleStateController;
  final ScaleStateCycle scaleStateCycle;
  final MagnifierTapCallback onTap;
  final HitTestBehavior gestureDetectorBehavior;
  final bool applyScale;

  @override
  State<StatefulWidget> createState() {
    return _MagnifierState();
  }
}

class _MagnifierState extends State<Magnifier> {
  Size _childSize;

  bool _controlledController;
  MagnifierController _controller;

  bool _controlledScaleStateController;
  MagnifierScaleStateController _scaleStateController;

  void _setChildSize(Size childSize) {
    _childSize = childSize;
  }

  @override
  void initState() {
    super.initState();
    _setChildSize(widget.childSize);
    if (widget.controller == null) {
      _controlledController = true;
      _controller = MagnifierController();
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = MagnifierScaleStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }
  }

  @override
  void didUpdateWidget(Magnifier oldWidget) {
    if (oldWidget.childSize != widget.childSize && widget.childSize != null) {
      setState(() {
        _setChildSize(widget.childSize);
      });
    }
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = MagnifierController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = MagnifierScaleStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleBoundaries = ScaleBoundaries(
          widget.minScale ?? 0.0,
          widget.maxScale ?? ScaleLevel(factor: double.infinity),
          widget.initialScale ?? ScaleLevel(ref: ScaleReference.contained),
          constraints.biggest,
          _childSize ?? constraints.biggest,
        );

        return MagnifierCore(
          child: widget.child,
          controller: _controller,
          scaleStateController: _scaleStateController,
          scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
          scaleBoundaries: scaleBoundaries,
          onTap: widget.onTap,
          gestureDetectorBehavior: widget.gestureDetectorBehavior,
          applyScale: widget.applyScale ?? true,
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
