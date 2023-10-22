import 'dart:async';
import 'dart:math';

import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:flutter/material.dart';

class FloatingNavBar extends StatefulWidget {
  final ScrollController? scrollController;
  final Stream<DraggableScrollbarEvent> events;
  final double childHeight;
  final Widget child;

  const FloatingNavBar({
    super.key,
    required this.scrollController,
    required this.events,
    required this.childHeight,
    required this.child,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double? _lastOffset;
  bool _isDragging = false;

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
        if (!mounted) return;
        setState(() {});
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
    widget.scrollController?.addListener(_onScrollChanged);
    _subscriptions.add(widget.events.listen(_onDraggableScrollBarEvent));
  }

  void _unregisterWidget(FloatingNavBar widget) {
    widget.scrollController?.removeListener(_onScrollChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }

  void _onScrollChanged() {
    final scrollController = widget.scrollController;
    if (scrollController == null) return;

    final offset = scrollController.offset;
    final delta = offset - (_lastOffset ?? offset);
    _lastOffset = offset;

    double? newValue;
    final childHeight = widget.childHeight;
    final after = scrollController.position.extentAfter;
    if (after < childHeight && delta > 0) {
      newValue = min(_controller.value, after / childHeight);
    } else if (!_isDragging || delta > 0) {
      newValue = _controller.value + delta / childHeight;
    }
    if (newValue != null) {
      _controller.value = newValue.clamp(0.0, 1.0);
    }
  }

  void _onDraggableScrollBarEvent(DraggableScrollbarEvent event) {
    switch (event) {
      case DraggableScrollbarEvent.dragStart:
        _isDragging = true;
      case DraggableScrollbarEvent.dragEnd:
        _isDragging = false;
    }
  }
}
