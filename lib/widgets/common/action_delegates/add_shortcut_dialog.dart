import 'package:aves/model/filters/filters.dart';
import 'package:flutter/material.dart';

import '../aves_dialog.dart';

class AddShortcutDialog extends StatefulWidget {
  final Set<CollectionFilter> filters;

  const AddShortcutDialog(this.filters);

  @override
  _AddShortcutDialogState createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<AddShortcutDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final filters = List.from(widget.filters)..sort();
    if (filters.isEmpty) {
      _nameController.text = 'Collection';
    } else {
      _nameController.text = filters.first.label;
    }
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
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Shortcut label',
        ),
        autofocus: true,
        maxLength: 25,
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
              child: Text('Add'.toUpperCase()),
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
