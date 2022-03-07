import 'package:flutter/material.dart';

class AvesPopupMenuButton<T> extends PopupMenuButton<T> {
  final VoidCallback? onMenuOpened;

  const AvesPopupMenuButton({
    Key? key,
    required PopupMenuItemBuilder<T> itemBuilder,
    T? initialValue,
    PopupMenuItemSelected<T>? onSelected,
    PopupMenuCanceled? onCanceled,
    String? tooltip,
    double? elevation,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    Widget? child,
    Widget? icon,
    Offset offset = Offset.zero,
    bool enabled = true,
    ShapeBorder? shape,
    Color? color,
    bool? enableFeedback,
    double? iconSize,
    this.onMenuOpened,
  }) : super(
          key: key,
          itemBuilder: itemBuilder,
          initialValue: initialValue,
          onSelected: onSelected,
          onCanceled: onCanceled,
          tooltip: tooltip,
          elevation: elevation,
          padding: padding,
          child: child,
          icon: icon,
          iconSize: iconSize,
          offset: offset,
          enabled: enabled,
          shape: shape,
          color: color,
          enableFeedback: enableFeedback,
        );

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
