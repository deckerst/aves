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
    Key? key,
    required this.entry,
  }) : super(key: key);

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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
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
    return pContext.join(entry.directory!, name + entry.extension!);
  }

  Future<void> _validate() async {
    final newName = _nameController.text;
    final path = _buildEntryPath(newName);
    final exists = newName.isNotEmpty && await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
    _isValidNotifier.value = newName.isNotEmpty && !exists;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.pop(context, _nameController.text);
    }
  }
}
