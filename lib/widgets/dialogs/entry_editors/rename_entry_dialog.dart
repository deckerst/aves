import 'dart:io';

import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import '../aves_dialog.dart';

class RenameEntryDialog extends StatefulWidget {
  final AvesEntry entry;

  const RenameEntryDialog({
    super.key,
    required this.entry,
  });

  @override
  State<RenameEntryDialog> createState() => _RenameEntryDialogState();
}

class _RenameEntryDialogState extends State<RenameEntryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _nameController.text = entry.filenameWithoutExtension ?? entry.sourceTitle ?? '';
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;
    final extensionSuffixText = '${Constants.fsi}${entry.extension}${Constants.pdi}';
    return AvesDialog(
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: context.l10n.renameEntryDialogLabel,
          // decoration prefix and suffix follow directionality
          // but the file extension should always be on the right
          prefixText: isRtl ? extensionSuffixText : null,
          suffixText: isRtl ? null : extensionSuffixText,
        ),
        autofocus: true,
        onChanged: (_) => _validate(),
        onSubmitted: (_) => _submit(context),
      ),
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

  String _buildEntryPath(String name) {
    if (name.isEmpty) return '';
    return pContext.join(entry.directory!, '$name${entry.extension}');
  }

  String get newName => _nameController.text.trimLeft();

  Future<void> _validate() async {
    final _newName = newName;
    final path = _buildEntryPath(_newName);
    final exists = _newName.isNotEmpty && await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
    _isValidNotifier.value = _newName.isNotEmpty && !exists;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(newName);
    }
  }
}
