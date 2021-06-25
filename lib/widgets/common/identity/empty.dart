import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final IconData? icon;
  final String text;
  final AlignmentGeometry alignment;

  const EmptyContent({
    Key? key,
    this.icon,
    required this.text,
    this.alignment = const FractionalOffset(.5, .35),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = Colors.blueGrey;
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: color,
            ),
            const SizedBox(height: 16)
          ],
          Text(
            text,
            style: const TextStyle(
              color: color,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
