import 'package:material_ui/material_ui.dart';

class const TextDropdownButton<T>({
  super.key,
  required final List<T> values,
  required final String Function(T value) valueText,
  final IconData Function(T value)? valueIcon,
  final T? value,
  final Widget? underline,
  final bool isExpanded = false,
  final double? itemHeight = kMinInteractiveDimension,
  final Color? dropdownColor,
  final EdgeInsetsGeometry? padding,
  required final ValueChanged<T?>? onChanged,
}) extends StatefulWidget {
  static TextStyle textStyle(BuildContext context) {
    final defaultDropdownStyle = Theme.of(context).textTheme.titleMedium!;
    return defaultDropdownStyle.copyWith(fontWeight: FontWeight.normal);
  }

  @override
  State<TextDropdownButton<T>> createState() => _TextDropdownButtonState<T>();
}

class _TextDropdownButtonState<T> extends State<TextDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: widget.values
          .map(
            (v) => DropdownMenuItem<T>(
              value: v,
              child: _buildItem(widget.valueText(v), widget.valueIcon?.call(v), selected: false),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => widget.values
          .map(
            (v) => DropdownMenuItem<T>(
              value: v,
              child: _buildItem(widget.valueText(v), widget.valueIcon?.call(v), selected: true),
            ),
          )
          .toList(),
      value: widget.value,
      style: TextDropdownButton.textStyle(context),
      underline: widget.underline,
      isExpanded: widget.isExpanded,
      itemHeight: widget.itemHeight,
      dropdownColor: widget.dropdownColor,
      padding: widget.padding,
      onChanged: widget.onChanged,
    );
  }

  static Widget _buildItem<T>(String text, IconData? icon, {required bool selected}) {
    final softWrap = selected ? false : null;
    final overflow = selected ? TextOverflow.fade : null;

    Widget child = icon != null
        ? Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8, bottom: 2),
                    child: Icon(icon),
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
            softWrap: softWrap,
            overflow: overflow,
          )
        : Text(
            text,
            softWrap: softWrap,
            overflow: overflow,
          );

    if (selected) {
      child = Align(
        alignment: .centerStart,
        child: child,
      );
    }

    return child;
  }
}
