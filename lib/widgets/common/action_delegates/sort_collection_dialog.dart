import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class SortCollectionDialog extends StatefulWidget {
  @override
  _SortCollectionDialogState createState() => _SortCollectionDialogState();
}

class _SortCollectionDialogState extends State<SortCollectionDialog> {
  SortFactor _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = settings.collectionSortFactor;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: 'Sort',
      scrollableContent: [
        _buildRadioListTile(SortFactor.date, 'By date'),
        _buildRadioListTile(SortFactor.size, 'By size'),
        _buildRadioListTile(SortFactor.name, 'By album & file name'),
      ],
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, _selectedSort),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(SortFactor sort, String title) => RadioListTile<SortFactor>(
        value: sort,
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
