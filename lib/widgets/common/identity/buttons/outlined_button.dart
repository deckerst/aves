import 'package:material_ui/material_ui.dart';

class const AvesOutlinedButton({
  super.key,
  final Widget? icon,
  required final String label,
  required final VoidCallback? onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.disabled) ? theme.disabledColor : theme.colorScheme.onSurface;
    });
    final style = ButtonStyle(
      foregroundColor: foreground,
      iconColor: foreground,
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(
          color: states.contains(WidgetState.disabled) ? theme.disabledColor : theme.colorScheme.primary,
        );
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
