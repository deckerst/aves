import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:material_ui/material_ui.dart';

class const ActionPanel({
  super.key,
  final bool highlight = false,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight ? theme.colorScheme.primary : Color.alphaBlend(theme.colorScheme.surfaceTint.withValues(alpha: .2), Themes.secondLayerColor(context));
    return AnimatedContainer(
      foregroundDecoration: BoxDecoration(
        color: color.withValues(alpha: .2),
        border: Border.fromBorderSide(
          BorderSide(
            color: color,
            width: highlight ? 2 : 1,
          ),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.all(16),
      duration: ADurations.quickActionHighlightAnimation,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: child,
      ),
    );
  }
}
