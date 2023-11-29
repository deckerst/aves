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
      side: MaterialStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(
          color: states.contains(MaterialState.disabled) ? theme.disabledColor : theme.colorScheme.primary,
        );
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        return states.contains(MaterialState.disabled) ? theme.disabledColor : theme.colorScheme.onPrimary;
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
