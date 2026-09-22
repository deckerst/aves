import 'package:material_ui/material_ui.dart';

// `RadioListTile` that can trigger `onChanged` on tap when already selected, if `reselectable` is true
class const ReselectableRadioListTile<T>({
  super.key,
  required final T value,
  final bool toggleable = false,
  final bool reselectable = false,
  final Color? activeColor,
  final Widget? title,
  final Widget? subtitle,
  final bool isThreeLine = false,
  final bool? dense,
  final Widget? secondary,
  final bool selected = false,
  final ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
  final bool autofocus = false,
}) extends StatelessWidget {
  this : assert(!isThreeLine || subtitle != null);

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
      case .leading:
      case .platform:
        leading = control;
        trailing = secondary;
      case .trailing:
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
