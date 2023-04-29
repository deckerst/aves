import 'package:flutter/material.dart';

class SliderListTile extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final EdgeInsetsGeometry titlePadding;
  final Widget Function(BuildContext context, double value)? titleTrailing;

  const SliderListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.titlePadding = const EdgeInsetsDirectional.only(start: 16),
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        overlayShape: RoundSliderOverlayShape(
          // align `Slider`s on `Switch`es by matching their overlay/reaction radius
          // `kRadialReactionRadius` is used when `SwitchThemeData.splashRadius` is undefined
          overlayRadius: kRadialReactionRadius,
        ),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleMedium!,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: titlePadding,
                child: Row(
                  children: [
                    Text(title),
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
      ),
    );
  }
}
