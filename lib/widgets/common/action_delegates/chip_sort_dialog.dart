import 'package:aves/model/source/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class ChipSortDialog extends StatefulWidget {
  final ChipSortFactor initialValue;

  const ChipSortDialog({@required this.initialValue});

  @override
  _ChipSortDialogState createState() => _ChipSortDialogState();
}

class _ChipSortDialogState extends State<ChipSortDialog> {
  ChipSortFactor _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: 'Sort',
      scrollableContent: [
        _buildRadioListTile(ChipSortFactor.date, 'By date'),
        _buildRadioListTile(ChipSortFactor.name, 'By name'),
      ],
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          key: Key('apply-button'),
          onPressed: () => Navigator.pop(context, _selectedSort),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(ChipSortFactor value, String title) => RadioListTile<ChipSortFactor>(
        key: Key(value.toString()),
        value: value,
        groupValue: _selectedSort,
        onChanged: (sort) => setState(() => _selectedSort = sort),
        title: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );
}
