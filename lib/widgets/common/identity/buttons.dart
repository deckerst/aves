import 'package:flutter/material.dart';

class AvesOutlinedButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback? onPressed;

  const AvesOutlinedButton({
    Key? key,
    this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ButtonStyle(
      side: MaterialStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(
          color: states.contains(MaterialState.disabled) ? theme.disabledColor : theme.colorScheme.secondary,
        );
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        return states.contains(MaterialState.disabled) ? theme.disabledColor : theme.colorScheme.onSecondary;
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
