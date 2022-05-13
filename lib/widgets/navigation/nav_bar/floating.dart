import 'dart:async';
import 'dart:math';

import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FloatingNavBar extends StatefulWidget {
  final ScrollController? scrollController;
  final Stream<DraggableScrollBarEvent> events;
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
  double _delta = 0;
  bool _isDragging = false;

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
    _subscriptions.add(widget.events.listen(_onDraggableScrollBarEvent));
  }

  void _unregisterWidget(FloatingNavBar widget) {
    widget.scrollController?.removeListener(_onScrollChange);
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

  void _onScrollChange() {
    final scrollController = widget.scrollController;
    if (scrollController == null) return;

    final offset = scrollController.offset;
    _delta += offset - (_lastOffset ?? offset);
    _lastOffset = offset;

    if (_isDragging) return;

    final after = scrollController.position.extentAfter;
    final childHeight = widget.childHeight;
    if (after < childHeight && scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      _controller.value = min(_controller.value, after / childHeight);
      _delta = 0;
      return;
    }

    if (_delta.abs() > _deltaThreshold) {
      if (_delta > 0) {
        _hide();
      } else {
        _show();
      }
    }
  }

  void _onDraggableScrollBarEvent(DraggableScrollBarEvent event) {
    switch (event) {
      case DraggableScrollBarEvent.dragStart:
        _isDragging = true;
        _hide();
        break;
      case DraggableScrollBarEvent.dragEnd:
        _isDragging = false;
        _show();
        break;
    }
  }

  void _show() {
    _controller.reverse();
    _delta = 0;
  }

  void _hide() {
    _controller.forward();
    _delta = 0;
  }
}
