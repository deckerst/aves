import 'package:aves/model/source/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class CollectionSortDialog extends StatefulWidget {
  final EntrySortFactor initialValue;

  const CollectionSortDialog({@required this.initialValue});

  @override
  _CollectionSortDialogState createState() => _CollectionSortDialogState();
}

class _CollectionSortDialogState extends State<CollectionSortDialog> {
  EntrySortFactor _selectedSort;

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
        _buildRadioListTile(EntrySortFactor.date, 'By date'),
        _buildRadioListTile(EntrySortFactor.size, 'By size'),
        _buildRadioListTile(EntrySortFactor.name, 'By album & file name'),
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

  Widget _buildRadioListTile(EntrySortFactor value, String title) => RadioListTile<EntrySortFactor>(
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
