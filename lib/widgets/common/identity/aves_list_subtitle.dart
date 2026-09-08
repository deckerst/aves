import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class AvesListSubtitle extends StatelessWidget {
  final String data;

  const new(
    this.data, {
    super.key,
  });

  // cf `_LisTileDefaultsM3` used by `ListTile`
  TextStyle _defaultTextStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurfaceVariant);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.listTileTheme.subtitleTextStyle ?? _defaultTextStyle(theme);
    final subtitleChangeShadowColor = theme.colorScheme.onSurface;
    return ChangeHighlightText(
      // provide key to refresh on theme brightness change
      key: ValueKey(subtitleChangeShadowColor),
      data,
      style: subtitleStyle.copyWith(
        shadows: [
          Shadow(
            color: subtitleChangeShadowColor.withAlpha(0),
            blurRadius: 0,
          ),
        ],
      ),
      changedStyle: subtitleStyle.copyWith(
        shadows: [
          Shadow(
            color: subtitleChangeShadowColor,
            blurRadius: 3,
          ),
        ],
      ),
      duration: context.read<DurationsData>().formTextStyleTransition,
    );
  }
}
