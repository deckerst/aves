import 'dart:io';

import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../aves_dialog.dart';

class RenameEntryDialog extends StatefulWidget {
  final ImageEntry entry;

  const RenameEntryDialog(this.entry);

  @override
  _RenameEntryDialogState createState() => _RenameEntryDialogState();
}

class _RenameEntryDialogState extends State<RenameEntryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
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
        onChanged: (_) => _validate(),
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return FlatButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text('Apply'.toUpperCase()),
            );
          },
        )
      ],
    );
  }

  Future<void> _validate() async {
    var newName = _nameController.text ?? '';
    if (newName.isNotEmpty) {
      newName += entry.extension;
    }
    final type = await FileSystemEntity.type(join(entry.directory, newName));
    _isValidNotifier.value = type == FileSystemEntityType.notFound;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _nameController.text);
}
