import 'dart:io';

import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class RenameAlbumDialog extends StatefulWidget {
  final String album;

  const RenameAlbumDialog({
    super.key,
    required this.album,
  });

  @override
  State<RenameAlbumDialog> createState() => _RenameAlbumDialogState();
}

class _RenameAlbumDialogState extends State<RenameAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  String get album => widget.album;

  String get initialValue => pContext.basename(album);

  @override
  void initState() {
    super.initState();
    _nameController.text = initialValue;
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _existsNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      content: ValueListenableBuilder<bool>(
          valueListenable: _existsNotifier,
          builder: (context, exists, child) {
            return TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.renameAlbumDialogLabel,
                helperText: exists ? context.l10n.renameAlbumDialogLabelAlreadyExistsHelper : '',
              ),
              autofocus: true,
              onChanged: (_) => _validate(),
              onSubmitted: (_) => _submit(context),
            );
          }),
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(context.l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  String _buildAlbumPath(String name) {
    if (name.isEmpty) return '';
    return pContext.join(pContext.dirname(album), name);
  }

  Future<void> _validate() async {
    final newName = _nameController.text;
    final path = _buildAlbumPath(newName);
    final exists = newName.isNotEmpty && await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
    _existsNotifier.value = exists && newName != initialValue;
    _isValidNotifier.value = newName.isNotEmpty;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_nameController.text);
    }
  }
}
