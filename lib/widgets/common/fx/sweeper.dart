import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Sweeper extends StatefulWidget {
  final WidgetBuilder builder;
  final double startAngle;
  final double sweepAngle;
  final Curve curve;
  final ValueNotifier<bool> toggledNotifier;
  final VoidCallback onSweepEnd;

  const Sweeper({
    Key key,
    @required this.builder,
    this.startAngle = -pi / 2,
    this.sweepAngle = pi / 4,
    this.curve = Curves.easeInOutCubic,
    @required this.toggledNotifier,
    this.onSweepEnd,
  }) : super(key: key);

  @override
  _SweeperState createState() => _SweeperState();
}

class _SweeperState extends State<Sweeper> with SingleTickerProviderStateMixin {
  AnimationController _angleAnimationController;
  Animation<double> _angle;
  bool _isAppearing = false;

  bool get isToggled => widget.toggledNotifier.value;

  static const opacityAnimationDurationMillis = 150;
  static const sweepingDurationMillis = 650;

  @override
  void initState() {
    super.initState();
    _angleAnimationController = AnimationController(
      duration: const Duration(milliseconds: sweepingDurationMillis),
      vsync: this,
    );
    _angle = Tween(
      begin: widget.startAngle - widget.sweepAngle / 2,
      end: widget.startAngle + pi * 2 - widget.sweepAngle / 2,
    ).animate(CurvedAnimation(
      parent: _angleAnimationController,
      curve: widget.curve,
    ));
    _angleAnimationController.addStatusListener(_onAnimationStatusChange);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(Sweeper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _angleAnimationController.removeStatusListener(_onAnimationStatusChange);
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(Sweeper widget) {
    widget.toggledNotifier.addListener(_onToggle);
  }

  void _unregisterWidget(Sweeper widget) {
    widget.toggledNotifier.removeListener(_onToggle);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isToggled && (_isAppearing || _angleAnimationController.status == AnimationStatus.forward) ? 1 : 0,
        duration: const Duration(milliseconds: opacityAnimationDurationMillis),
        child: ValueListenableBuilder<double>(
            valueListenable: _angleAnimationController,
            builder: (context, value, child) {
              return ClipPath(
                child: widget.builder(context),
                clipper: _SweepClipPath(
                  startAngle: _angle.value,
                  sweepAngle: widget.sweepAngle,
                ),
              );
            }),
      ),
    );
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    setState(() {});
    if (status == AnimationStatus.completed) {
      widget.onSweepEnd?.call();
    }
  }

  Future<void> _onToggle() async {
    if (isToggled) {
      _isAppearing = true;
      setState(() {});
      await Future.delayed(Duration(milliseconds: (opacityAnimationDurationMillis * timeDilation).toInt()));
      _isAppearing = false;
      _angleAnimationController.forward();
    } else {
      await Future.delayed(Duration(milliseconds: (opacityAnimationDurationMillis * timeDilation).toInt()));
      _angleAnimationController.reset();
    }
    setState(() {});
  }
}

class _SweepClipPath extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;

  const _SweepClipPath({@required this.startAngle, @required this.sweepAngle});

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final diagonal = sqrt(width * width + height * height);
    return Path()
      ..moveTo(centerX, centerY)
      ..addArc(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: diagonal,
          height: diagonal,
        ),
        startAngle,
        sweepAngle,
      )
      ..lineTo(centerX, centerY);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
