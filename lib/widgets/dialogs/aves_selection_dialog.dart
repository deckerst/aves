import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'aves_dialog.dart';

typedef TextBuilder<T> = String Function(T value);

class AvesSelectionDialog<T> extends StatefulWidget {
  final T initialValue;
  final Map<T, String> options;
  final TextBuilder<T>? optionSubtitleBuilder;
  final String title;

  const AvesSelectionDialog({
    Key? key,
    required this.initialValue,
    required this.options,
    this.optionSubtitleBuilder,
    required this.title,
  }) : super(key: key);

  @override
  _AvesSelectionDialogState<T> createState() => _AvesSelectionDialogState<T>();
}

class _AvesSelectionDialogState<T> extends State<AvesSelectionDialog<T>> {
  late T _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      context: context,
      title: widget.title,
      scrollableContent: widget.options.entries.map((kv) => _buildRadioListTile(kv.key, kv.value)).toList(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(T value, String title) {
    final subtitle = widget.optionSubtitleBuilder?.call(value);
    return ReselectableRadioListTile<T>(
      // key is expected by test driver
      key: Key(value.toString()),
      value: value,
      groupValue: _selectedValue,
      onChanged: (v) => Navigator.pop(context, v),
      reselectable: true,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            )
          : null,
    );
  }
}
