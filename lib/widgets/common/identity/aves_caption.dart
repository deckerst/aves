import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesCaption extends StatelessWidget {
  final String data;

  const AvesCaption(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall!;
    final subtitleChangeShadowColor = theme.colorScheme.onBackground;
    return ChangeHighlightText(
      // provide key to refresh on theme brightness change
      key: ValueKey(subtitleChangeShadowColor),
      data,
      style: subtitleStyle.copyWith(
        shadows: [
          Shadow(
            color: subtitleChangeShadowColor.withOpacity(0),
            blurRadius: 0,
          )
        ],
      ),
      changedStyle: subtitleStyle.copyWith(
        shadows: [
          Shadow(
            color: subtitleChangeShadowColor,
            blurRadius: 3,
          )
        ],
      ),
      duration: context.read<DurationsData>().formTextStyleTransition,
    );
  }
}
