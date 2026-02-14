import 'package:flutter/material.dart';

// `RadioListTile` that can trigger `onChanged` on tap when already selected, if `reselectable` is true
class ReselectableRadioListTile<T> extends StatelessWidget {
  final T value;
  final bool toggleable;
  final bool reselectable;
  final Color? activeColor;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool isThreeLine;
  final bool? dense;
  final bool selected;
  final ListTileControlAffinity controlAffinity;
  final bool autofocus;

  const ReselectableRadioListTile({
    super.key,
    required this.value,
    this.toggleable = false,
    this.reselectable = false,
    this.activeColor,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.autofocus = false,
  }) : assert(!isThreeLine || subtitle != null);

  @override
  Widget build(BuildContext context) {
    final Widget control = Radio<T>(
      value: value,
      toggleable: toggleable,
      activeColor: activeColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      autofocus: autofocus,
    );
    Widget? leading, trailing;
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
      case ListTileControlAffinity.platform:
        leading = control;
        trailing = secondary;
      case ListTileControlAffinity.trailing:
        leading = secondary;
        trailing = control;
    }
    final groupRegistry = RadioGroup.maybeOf<T>(context);
    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: activeColor ?? Theme.of(context).colorScheme.primary,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          isThreeLine: isThreeLine,
          dense: dense,
          enabled: groupRegistry != null,
          onTap: groupRegistry != null
              ? () {
                  final selected = value == groupRegistry.groupValue;
                  if (toggleable && selected) {
                    groupRegistry.onChanged(null);
                  } else if (reselectable || !selected) {
                    groupRegistry.onChanged(value);
                  }
                }
              : null,
          selected: selected,
          autofocus: autofocus,
        ),
      ),
    );
  }
}
