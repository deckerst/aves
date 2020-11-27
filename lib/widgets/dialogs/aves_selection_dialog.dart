import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'aves_dialog.dart';

typedef TextBuilder<T> = String Function(T value);

class AvesSelectionDialog<T> extends StatefulWidget {
  final T initialValue;
  final Map<T, String> options;
  final TextBuilder<T> optionSubtitleBuilder;
  final String title;

  const AvesSelectionDialog({
    @required this.initialValue,
    @required this.options,
    this.optionSubtitleBuilder,
    @required this.title,
  });

  @override
  _AvesSelectionDialogState<T> createState() => _AvesSelectionDialogState<T>();
}

class _AvesSelectionDialogState<T> extends State<AvesSelectionDialog> {
  T _selectedValue;

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
          child: Text('Cancel'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(T value, String title) {
    return ReselectableRadioListTile<T>(
      key: Key(value.toString()),
      value: value,
      groupValue: _selectedValue,
      onChanged: (v) {
        _selectedValue = v;
        Navigator.pop(context, _selectedValue);
        setState(() {});
      },
      reselectable: true,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      subtitle: widget.optionSubtitleBuilder != null
          ? Text(
              widget.optionSubtitleBuilder(value),
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            )
          : null,
    );
  }
}
