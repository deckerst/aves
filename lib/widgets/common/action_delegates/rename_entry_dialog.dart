import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';

import '../aves_dialog.dart';

class RenameEntryDialog extends StatefulWidget {
  final ImageEntry entry;

  const RenameEntryDialog(this.entry);

  @override
  _RenameEntryDialogState createState() => _RenameEntryDialogState();
}

class _RenameEntryDialogState extends State<RenameEntryDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _nameController.text = entry.filenameWithoutExtension ?? entry.sourceTitle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      content: TextField(
        controller: _nameController,
        autofocus: true,
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, _nameController.text),
          child: Text('Apply'.toUpperCase()),
        ),
      ],
    );
  }
}
