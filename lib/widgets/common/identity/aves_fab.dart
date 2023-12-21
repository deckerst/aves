import 'package:aves/theme/icons.dart';
import 'package:flutter/material.dart';

class AvesFab extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const AvesFab({
    super.key,
    required this.tooltip,
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
        onPressed: onPressed,
        child: const Icon(AIcons.apply),
      ),
    );
  }
}
