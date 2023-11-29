import 'package:flutter/material.dart';

class TextDropdownButton<T> extends StatefulWidget {
  final List<T> values;
  final String Function(T value) valueText;
  final IconData Function(T value)? valueIcon;
  final T? value;
  final Widget? underline;
  final bool isExpanded;
  final double? itemHeight;
  final Color? dropdownColor;
  final ValueChanged<T?>? onChanged;

  const TextDropdownButton({
    super.key,
    required this.values,
    required this.valueText,
    this.valueIcon,
    this.value,
    this.underline,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.dropdownColor,
    required this.onChanged,
  });

  @override
  State<TextDropdownButton<T>> createState() => _TextDropdownButtonState<T>();
}

class _TextDropdownButtonState<T> extends State<TextDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: widget.values
          .map((v) => DropdownMenuItem<T>(
                value: v,
                child: _buildItem(widget.valueText(v), widget.valueIcon?.call(v), selected: false),
              ))
          .toList(),
      selectedItemBuilder: (context) => widget.values
          .map((v) => DropdownMenuItem<T>(
                value: v,
                child: _buildItem(widget.valueText(v), widget.valueIcon?.call(v), selected: true),
              ))
          .toList(),
      value: widget.value,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.normal),
      underline: widget.underline,
      isExpanded: widget.isExpanded,
      itemHeight: widget.itemHeight,
      dropdownColor: widget.dropdownColor,
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
        alignment: AlignmentDirectional.centerStart,
        child: child,
      );
    }

    return child;
  }
}
