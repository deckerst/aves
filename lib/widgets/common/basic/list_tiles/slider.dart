import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:material_ui/material_ui.dart';

class const SliderListTile({
  super.key,
  required final TitleBuilder title,
  required final double value,
  required final ValueChanged<double>? onChanged,
  final double min = 0.0,
  final double max = 1.0,
  final int? divisions,
  final EdgeInsetsGeometry titlePadding = const EdgeInsetsDirectional.only(start: 16),
  final Widget Function(BuildContext context, double value)? titleTrailing,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listTileTitleTextStyle = ListTileTheme.of(context).titleTextStyle ?? theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onSurface);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayShape: const RoundSliderOverlayShape(
          // align `Slider`s on `Switch`es by matching their overlay/reaction radius
          // `kRadialReactionRadius` is used when `SwitchThemeData.splashRadius` is undefined
          overlayRadius: kRadialReactionRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: titlePadding,
              child: Row(
                children: [
                  Text(
                    title(context) ?? '?',
                    style: listTileTitleTextStyle,
                  ),
                  const Spacer(),
                  if (titleTrailing != null) titleTrailing!(context, value),
                ],
              ),
            ),
            Padding(
              // match `SwitchListTile.contentPadding`
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: min,
                max: max,
                divisions: divisions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
