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
    final style = ButtonStyle(
      side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Theme.of(context).colorScheme.secondary)),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
