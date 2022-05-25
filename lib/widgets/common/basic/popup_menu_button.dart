import 'package:flutter/material.dart';

class AvesPopupMenuButton<T> extends PopupMenuButton<T> {
  final VoidCallback? onMenuOpened;

  const AvesPopupMenuButton({
    super.key,
    required super.itemBuilder,
    super.initialValue,
    super.onSelected,
    super.onCanceled,
    super.tooltip,
    super.elevation,
    super.padding = const EdgeInsets.all(8.0),
    super.child,
    super.icon,
    super.offset = Offset.zero,
    super.enabled = true,
    super.shape,
    super.color,
    super.enableFeedback,
    super.iconSize,
    this.onMenuOpened,
  });

  @override
  PopupMenuButtonState<T> createState() => _AvesPopupMenuButtonState<T>();
}

class _AvesPopupMenuButtonState<T> extends PopupMenuButtonState<T> {
  @override
  void showButtonMenu() {
    (widget as AvesPopupMenuButton).onMenuOpened?.call();
    super.showButtonMenu();
  }
}
