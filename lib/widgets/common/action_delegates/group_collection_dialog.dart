import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../dialog.dart';

class GroupCollectionDialog extends StatefulWidget {
  @override
  _GroupCollectionDialogState createState() => _GroupCollectionDialogState();
}

class _GroupCollectionDialogState extends State<GroupCollectionDialog> {
  GroupFactor _selectedGroup;

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
        _buildRadioListTile(GroupFactor.album, 'By album'),
        _buildRadioListTile(GroupFactor.month, 'By month'),
        _buildRadioListTile(GroupFactor.day, 'By day'),
        _buildRadioListTile(GroupFactor.none, 'Do not group'),
      ],
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, _selectedGroup),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildRadioListTile(GroupFactor group, String title) => RadioListTile<GroupFactor>(
        value: group,
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
