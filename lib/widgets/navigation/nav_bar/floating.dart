import 'package:flutter/material.dart';

class FloatingNavBar extends StatefulWidget {
  final ScrollController? scrollController;
  final Widget child;

  const FloatingNavBar({
    Key? key,
    required this.scrollController,
    required this.child,
  }) : super(key: key);

  @override
  _FloatingNavBarState createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double? _lastOffset;
  double _delta = 0;

  static const double _deltaThreshold = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(FloatingNavBar widget) {
    _lastOffset = null;
    _delta = 0;
    widget.scrollController?.addListener(_onScrollChange);
  }

  void _unregisterWidget(FloatingNavBar widget) {
    widget.scrollController?.removeListener(_onScrollChange);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }

  void _onScrollChange() {
    final scrollController = widget.scrollController;
    if (scrollController == null) return;

    final offset = scrollController.offset;
    _delta += offset - (_lastOffset ?? offset);
    _lastOffset = offset;

    if (_delta.abs() > _deltaThreshold) {
      if (_delta > 0) {
        // hide
        _controller.forward();
      } else {
        // show
        _controller.reverse();
      }
      _delta = 0;
    }
  }
}
