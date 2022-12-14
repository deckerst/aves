import 'dart:async';
import 'dart:math';

import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Sweeper extends StatefulWidget {
  final WidgetBuilder builder;
  final double startAngle;
  final double sweepAngle;
  final Curve curve;
  final ValueNotifier<bool> toggledNotifier;
  final bool centerSweep;
  final VoidCallback? onSweepEnd;

  const Sweeper({
    super.key,
    required this.builder,
    this.startAngle = -pi / 2,
    this.sweepAngle = pi / 4,
    this.curve = Curves.easeInOutCubic,
    required this.toggledNotifier,
    this.centerSweep = true,
    this.onSweepEnd,
  });

  @override
  State<Sweeper> createState() => _SweeperState();
}

class _SweeperState extends State<Sweeper> with SingleTickerProviderStateMixin {
  late AnimationController _angleAnimationController;
  late Animation<double> _angle;
  bool _isAppearing = false;

  bool get isToggled => widget.toggledNotifier.value;

  @override
  void initState() {
    super.initState();
    _angleAnimationController = AnimationController(
      duration: Durations.sweepingAnimation,
      vsync: this,
    );
    final startAngle = widget.startAngle;
    final sweepAngle = widget.sweepAngle;
    final centerSweep = widget.centerSweep;
    _angle = Tween(
      begin: startAngle - sweepAngle * (centerSweep ? .5 : 0),
      end: startAngle + pi * 2 - sweepAngle * (centerSweep ? .5 : 1),
    ).animate(CurvedAnimation(
      parent: _angleAnimationController,
      curve: widget.curve,
    ));
    _angleAnimationController.addStatusListener(_onAnimationStatusChanged);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant Sweeper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _angleAnimationController.removeStatusListener(_onAnimationStatusChanged);
    _angleAnimationController.dispose();
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
        duration: Durations.sweeperOpacityAnimation,
        child: ValueListenableBuilder<double>(
            valueListenable: _angleAnimationController,
            builder: (context, value, child) {
              return ClipPath(
                clipper: _SweepClipPath(
                  startAngle: _angle.value,
                  sweepAngle: widget.sweepAngle,
                ),
                child: widget.builder(context),
              );
            }),
      ),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    setState(() {});
    if (status == AnimationStatus.completed) {
      widget.onSweepEnd?.call();
    }
  }

  Future<void> _onToggle() async {
    if (isToggled) {
      _isAppearing = true;
      setState(() {});
      await Future.delayed(Durations.sweeperOpacityAnimation * timeDilation);
      _isAppearing = false;
      if (mounted) {
        _angleAnimationController.reset();
        unawaited(_angleAnimationController.forward());
      }
    }
    if (mounted) {
      setState(() {});
    }
  }
}

class _SweepClipPath extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;

  const _SweepClipPath({required this.startAngle, required this.sweepAngle});

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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
