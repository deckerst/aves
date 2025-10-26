import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class RenameDynamicAlbumDialog extends StatefulWidget {
  static const routeName = '/dialog/rename_dynamic_album';

  final String name;

  const RenameDynamicAlbumDialog({
    super.key,
    required this.name,
  });

  @override
  State<RenameDynamicAlbumDialog> createState() => _RenameDynamicAlbumDialogState();
}

class _RenameDynamicAlbumDialogState extends State<RenameDynamicAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  String get initialValue => widget.name;

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
                helperText: exists ? context.l10n.dynamicAlbumAlreadyExists : '',
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

  String? _formatAlbumName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;

    return name;
  }

  Future<void> _validate() async {
    final newName = _formatAlbumName();
    final exists = dynamicAlbums.contains(newName);
    _isValidNotifier.value = newName != null && !exists;
    _existsNotifier.value = exists && newName != initialValue;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_formatAlbumName());
    }
  }
}
