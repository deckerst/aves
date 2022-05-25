import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  final bool highlight;
  final Widget child;

  const ActionPanel({
    super.key,
    this.highlight = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Theme.of(context).colorScheme.secondary : Colors.blueGrey;
    return AnimatedContainer(
      foregroundDecoration: BoxDecoration(
        color: color.withOpacity(.2),
        border: Border.fromBorderSide(BorderSide(
          color: color,
          width: highlight ? 2 : 1,
        )),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.all(16),
      duration: Durations.quickActionHighlightAnimation,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: child,
      ),
    );
  }
}
