import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class AddShortcutDialog extends StatefulWidget {
  final String defaultName;

  const AddShortcutDialog({
    @required this.defaultName,
  });

  @override
  _AddShortcutDialogState createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<AddShortcutDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.defaultName;
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
          labelText: context.l10n.addShortcutDialogLabel,
        ),
        autofocus: true,
        maxLength: 25,
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
              child: Text(context.l10n.addShortcutButtonLabel),
            );
          },
        )
      ],
    );
  }

  Future<void> _validate() async {
    final name = _nameController.text ?? '';
    _isValidNotifier.value = name.isNotEmpty;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _nameController.text);
}
