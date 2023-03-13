import 'package:flutter/material.dart';

class PopupMenuItemContainer<T> extends PopupMenuEntry<T> {
  final Widget child;

  const PopupMenuItemContainer({
    super.key,
    this.height = kMinInteractiveDimension,
    required this.child,
  });

  @override
  final double height;

  @override
  bool represents(void value) => false;

  @override
  State<PopupMenuItemContainer> createState() => _TransitionPopupMenuItemState();
}

class _TransitionPopupMenuItemState extends State<PopupMenuItemContainer> {
  @override
  Widget build(BuildContext context) {
    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: widget.child,
      ),
    );
  }
}
