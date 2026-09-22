import 'package:aves/theme/durations.dart';
import 'package:material_ui/material_ui.dart';

class const Rotator({
  super.key,
  required final Listenable listenable,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<Rotator> createState() => _RotatorState();
}

class _RotatorState extends State<Rotator> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turnAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ADurations.rotatorAnimation,
      vsync: this,
    );
    _turnAnimation = Tween<double>(begin: 0, end: .5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuart,
      ),
    );
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant Rotator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.listenable != widget.listenable) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _controller.dispose();
    super.dispose();
  }

  void _registerWidget(Rotator widget) {
    widget.listenable.addListener(_triggerAnimation);
  }

  void _unregisterWidget(Rotator widget) {
    widget.listenable.removeListener(_triggerAnimation);
  }

  void _triggerAnimation() => _controller.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turnAnimation,
      child: widget.child,
    );
  }
}
