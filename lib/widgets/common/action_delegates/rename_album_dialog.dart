import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../aves_dialog.dart';

class RenameAlbumDialog extends StatefulWidget {
  final String album;

  const RenameAlbumDialog(this.album);

  @override
  _RenameAlbumDialogState createState() => _RenameAlbumDialogState();
}

class _RenameAlbumDialogState extends State<RenameAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  String get album => widget.album;

  String get initialValue => path.basename(album);

  @override
  void initState() {
    super.initState();
    _nameController.text = initialValue;
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
      content: ValueListenableBuilder<bool>(
          valueListenable: _existsNotifier,
          builder: (context, exists, child) {
            return TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'New name',
                helperText: exists ? 'Album already exists' : '',
              ),
              autofocus: true,
              onChanged: (_) => _validate(),
              onSubmitted: (_) => _submit(context),
            );
          }),
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

  String _buildAlbumPath(String name) {
    if (name == null || name.isEmpty) return '';
    return path.join(path.dirname(album), name);
  }

  Future<void> _validate() async {
    final newName = _nameController.text ?? '';
    final path = _buildAlbumPath(newName);
    final exists = newName.isNotEmpty && await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
    _existsNotifier.value = exists && newName != initialValue;
    _isValidNotifier.value = newName.isNotEmpty && !exists;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _nameController.text);
}
