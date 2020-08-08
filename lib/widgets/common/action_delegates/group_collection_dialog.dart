import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    return AlertDialog(
      title: Text('Group'),
      content: Container(
        // workaround because the dialog tries
        // to size itself to the content intrinsic size,
        // but the `ListView` viewport does not have one
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildRadioListTile(GroupFactor.album, 'By album'),
            _buildRadioListTile(GroupFactor.month, 'By month'),
            _buildRadioListTile(GroupFactor.day, 'By day'),
            _buildRadioListTile(GroupFactor.none, 'Do not group'),
          ],
        ),
      ),
      contentPadding: EdgeInsets.only(top: 20),
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
      actionsPadding: Constants.dialogActionsPadding,
      shape: Constants.dialogShape,
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
