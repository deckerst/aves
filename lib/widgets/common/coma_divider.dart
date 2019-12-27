import 'package:flutter/material.dart';

class ComaDivider extends StatelessWidget {
  final Color color;
  final Alignment alignment;

  const ComaDivider({
    this.color = Colors.white70,
    this.alignment = Alignment.center,
  });

  double get peakStop => (alignment.x + 1 / 2).clamp(.02, .98);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: [
            0,
            peakStop,
            1,
          ],
          colors: [
            Colors.transparent,
            color,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
