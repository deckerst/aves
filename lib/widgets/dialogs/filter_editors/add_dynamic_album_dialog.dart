import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class AddDynamicAlbumDialog extends StatefulWidget {
  static const routeName = '/dialog/add_dynamic_album';

  const AddDynamicAlbumDialog({super.key});

  @override
  State<AddDynamicAlbumDialog> createState() => _AddDynamicAlbumDialogState();
}

class _AddDynamicAlbumDialogState extends State<AddDynamicAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
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
    final l10n = context.l10n;

    return AvesDialog(
      title: l10n.newDynamicAlbumDialogTitle,
      content: ValueListenableBuilder<bool>(
          valueListenable: _existsNotifier,
          builder: (context, exists, child) {
            return TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.newAlbumDialogNameLabel,
                helperText: exists ? l10n.dynamicAlbumAlreadyExists : '',
              ),
              autofocus: true,
              onChanged: (_) => _validate(),
              onSubmitted: (_) => _submit(context),
            );
          }),
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _existsNotifier,
          builder: (context, albumExists, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isValidNotifier,
              builder: (context, isValid, child) {
                return TextButton(
                  onPressed: isValid ? () => _submit(context) : null,
                  child: Text(albumExists ? l10n.showButtonLabel : l10n.createAlbumButtonLabel),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String? _formatAlbumName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;

    return name;
  }

  void _validate() {
    final name = _formatAlbumName();
    final isValid = name != null;
    _isValidNotifier.value = isValid;
    _existsNotifier.value = isValid && dynamicAlbums.contains(name);
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_formatAlbumName());
    }
  }
}
