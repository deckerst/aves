import 'dart:io';

import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'aves_dialog.dart';

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
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      context: context,
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'New name',
          suffixText: entry.extension,
        ),
        autofocus: true,
        onChanged: (_) => _validate(),
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text('Apply'.toUpperCase()),
            );
          },
        )
      ],
    );
  }

  String _buildEntryPath(String name) {
    if (name == null || name.isEmpty) return '';
    return path.join(entry.directory, name + entry.extension);
  }

  Future<void> _validate() async {
    final newName = _nameController.text ?? '';
    final path = _buildEntryPath(newName);
    final exists = newName.isNotEmpty && await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
    _isValidNotifier.value = newName.isNotEmpty && !exists;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _nameController.text);
}
