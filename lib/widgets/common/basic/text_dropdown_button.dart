import 'package:flutter/material.dart';

class TextDropdownButton<T> extends DropdownButton<T> {
  TextDropdownButton({
    super.key,
    required List<T> values,
    required String Function(T value) valueText,
    IconData Function(T value)? valueIcon,
    super.value,
    super.hint,
    super.disabledHint,
    required super.onChanged,
    super.onTap,
    super.elevation,
    super.style,
    super.underline,
    super.icon,
    super.iconDisabledColor,
    super.iconEnabledColor,
    super.iconSize,
    super.isDense,
    super.isExpanded,
    super.itemHeight,
    super.focusColor,
    super.focusNode,
    super.autofocus,
    super.dropdownColor,
    super.menuMaxHeight,
    super.enableFeedback,
    super.alignment,
    super.borderRadius,
  }) : super(
          items: values
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: _buildItem(valueText(v), valueIcon?.call(v), selected: false),
                  ))
              .toList(),
          selectedItemBuilder: (context) => values
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: _buildItem(valueText(v), valueIcon?.call(v), selected: true),
                  ))
              .toList(),
        );

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
