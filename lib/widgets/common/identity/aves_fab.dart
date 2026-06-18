import 'package:flutter/material.dart';

class AvesFab extends StatelessWidget {
  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  const AvesFab({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: FloatingActionButton(
        tooltip: tooltip,
        backgroundColor: onPressed != null ? null : Theme.of(context).disabledColor,
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}
