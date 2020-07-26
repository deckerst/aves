import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final IconData icon;
  final String text;
  final AlignmentGeometry alignment;

  const EmptyContent({
    @required this.icon,
    @required this.text,
    this.alignment = const FractionalOffset(.5, .35),
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF607D8B);
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: color,
          ),
          SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontFamily: 'Concourse',
            ),
          ),
        ],
      ),
    );
  }
}
