import 'package:flutter/material.dart';

class TextDropdownButton<T> extends DropdownButton<T> {
  TextDropdownButton({
    super.key,
    required List<T> values,
    required String Function(T value) valueText,
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
                    child: Text(valueText(v)),
                  ))
              .toList(),
          selectedItemBuilder: (context) => values
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        valueText(v),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ))
              .toList(),
        );
}
