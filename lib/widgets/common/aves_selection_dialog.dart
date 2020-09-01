import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'aves_dialog.dart';

class AvesSelectionDialog<T> extends StatefulWidget {
  final T initialValue;
  final Map<T, String> options;
  final String title;

  const AvesSelectionDialog({
    @required this.initialValue,
    @required this.options,
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
      title: widget.title,
      scrollableContent: widget.options.entries.map((kv) => _buildRadioListTile(kv.key, kv.value)).toList(),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          key: Key('apply-button'),
          onPressed: () => Navigator.pop(context, _selectedValue),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(T value, String title) => RadioListTile<T>(
        key: Key(value.toString()),
        value: value,
        groupValue: _selectedValue,
        onChanged: (v) => setState(() => _selectedValue = v),
        title: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );
}
