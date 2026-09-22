import 'dart:async';
import 'dart:math';

import 'package:aves/theme/durations.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

class const Sweeper({
  super.key,
  required final WidgetBuilder builder,
  final double startAngle = -pi / 2,
  final double sweepAngle = pi / 4,
  required final ValueNotifier<bool> toggledNotifier,
  final bool centerSweep = true,
  final VoidCallback? onSweepEnd,
}) extends StatefulWidget {
  @override
  State<Sweeper> createState() => _SweeperState();
}

class _SweeperState extends State<Sweeper> with SingleTickerProviderStateMixin {
  late AnimationController _angleAnimationController;
  late CurvedAnimation _angleAnimation;
  late Animation<double> _angle;
  bool _isAppearing = false;

  bool get isToggled => widget.toggledNotifier.value;

  @override
  void initState() {
    super.initState();
    _angleAnimationController = AnimationController(
      duration: ADurations.sweepingAnimation,
      vsync: this,
    );
    final startAngle = widget.startAngle;
    final sweepAngle = widget.sweepAngle;
    final centerSweep = widget.centerSweep;
    _angleAnimation = CurvedAnimation(
      parent: _angleAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _angle = Tween(
      begin: startAngle - sweepAngle * (centerSweep ? .5 : 0),
      end: startAngle + pi * 2 - sweepAngle * (centerSweep ? .5 : 1),
    ).animate(_angleAnimation);
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
    _angleAnimation.dispose();
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
        duration: ADurations.sweeperOpacityAnimation,
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
          },
        ),
      ),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    setState(() {});
    if (status.isCompleted) {
      widget.onSweepEnd?.call();
    }
  }

  Future<void> _onToggle() async {
    if (isToggled) {
      _isAppearing = true;
      setState(() {});
      await Future.delayed(ADurations.sweeperOpacityAnimation * timeDilation);
      _isAppearing = false;
      if (!mounted) return;
      _angleAnimationController.reset();
      unawaited(_angleAnimationController.forward());
    }
    if (!mounted) return;
    setState(() {});
  }
}

class const _SweepClipPath({
  required final double startAngle,
  required final double sweepAngle,
}) extends CustomClipper<Path> {
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
