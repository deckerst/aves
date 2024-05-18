import 'package:flutter/material.dart';

class AvesOutlinedButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback? onPressed;

  const AvesOutlinedButton({
    super.key,
    this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ButtonStyle(
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(
          color: states.contains(WidgetState.disabled) ? theme.disabledColor : theme.colorScheme.primary,
        );
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.disabled) ? theme.disabledColor : theme.colorScheme.onSurface;
      }),
    );
    return icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: icon!,
            label: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );
  }
}
