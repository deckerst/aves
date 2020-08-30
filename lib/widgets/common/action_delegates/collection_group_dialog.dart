import 'package:aves/model/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class CollectionGroupDialog extends StatefulWidget {
  @override
  _CollectionGroupDialogState createState() => _CollectionGroupDialogState();
}

class _CollectionGroupDialogState extends State<CollectionGroupDialog> {
  EntryGroupFactor _selectedGroup;

  @override
  void initState() {
    super.initState();
    _selectedGroup = settings.collectionGroupFactor;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: 'Group',
      scrollableContent: [
        _buildRadioListTile(EntryGroupFactor.album, 'By album'),
        _buildRadioListTile(EntryGroupFactor.month, 'By month'),
        _buildRadioListTile(EntryGroupFactor.day, 'By day'),
        _buildRadioListTile(EntryGroupFactor.none, 'Do not group'),
      ],
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          key: Key('apply-button'),
          onPressed: () => Navigator.pop(context, _selectedGroup),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(EntryGroupFactor value, String title) => RadioListTile<EntryGroupFactor>(
        key: Key(value.toString()),
        value: value,
        groupValue: _selectedGroup,
        onChanged: (group) => setState(() => _selectedGroup = group),
        title: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );
}
