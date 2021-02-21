import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final IconData icon;
  final String text;
  final AlignmentGeometry alignment;

  const EmptyContent({
    this.icon,
    @required this.text,
    this.alignment = const FractionalOffset(.5, .35),
  });

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
            SizedBox(height: 16)
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
