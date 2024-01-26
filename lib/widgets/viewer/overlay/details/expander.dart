import 'package:flutter/material.dart';

class OverlayRowExpander extends StatelessWidget {
  final ValueNotifier<bool> expandedNotifier;
  final Widget child;

  const OverlayRowExpander({
    super.key,
    required this.expandedNotifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: expandedNotifier,
      builder: (context, expanded, child) {
        final parent = DefaultTextStyle.of(context);
        return DefaultTextStyle(
          key: key,
          style: parent.style,
          textAlign: parent.textAlign,
          softWrap: expanded,
          overflow: parent.overflow,
          maxLines: expanded ? 16 : 1,
          textWidthBasis: parent.textWidthBasis,
          child: child!,
        );
      },
      child: child,
    );
  }
}
