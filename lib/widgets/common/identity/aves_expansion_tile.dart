import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/divider.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const AvesExpansionTile({
  super.key,
  String? value,
  final Widget? leading,
  required final String title,
  required final KnownLocale? locale,
  final Color? highlightColor,
  final ValueNotifier<String?>? expandedNotifier,
  final bool initiallyExpanded = false,
  final bool showHighlight = true,
  required final List<Widget> children,
}) extends StatelessWidget {
  final String value = value ?? title;

  @override
  Widget build(BuildContext context) {
    final enabled = children.isNotEmpty == true;
    Widget titleChild = HighlightTitle(
      title: title,
      locale: locale,
      color: highlightColor,
      enabled: enabled,
      showHighlight: showHighlight,
    );
    if (leading != null) {
      titleChild = Row(
        children: [
          leading!,
          const SizedBox(width: 8),
          Expanded(child: titleChild),
        ],
      );
    }

    final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ExpansionTileCard(
      // key is expected by test driver
      key: Key('tilecard-$value'),
      value: value,
      expandedNotifier: expandedNotifier,
      title: titleChild,
      expandable: enabled,
      initiallyExpanded: initiallyExpanded,
      finalPadding: const EdgeInsets.symmetric(vertical: 6.0),
      baseColor: Themes.firstLayerColor(context),
      expandedTextColor: colorScheme.onSurface,
      duration: animationDuration,
      shadowColor: theme.shadowColor,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const ThinDivider(),
          const SizedBox(height: 4),
          if (enabled) ...children,
        ],
      ),
    );
  }
}
