import 'package:aves/model/grouping/common.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class CreateGroupDialog extends StatefulWidget {
  static const routeName = '/dialog/create_group';

  final FilterGrouping grouping;
  final Uri? parentGroupUri;

  const CreateGroupDialog({
    super.key,
    required this.grouping,
    required this.parentGroupUri,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  FilterGrouping get grouping => widget.grouping;

  Uri? get parentGroupUri => widget.parentGroupUri;

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
      title: l10n.newGroupDialogTitle,
      content: ValueListenableBuilder<bool>(
        valueListenable: _existsNotifier,
        builder: (context, exists, child) {
          return TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.newGroupDialogNameLabel,
              helperText: exists ? l10n.groupAlreadyExists : '',
            ),
            autofocus: true,
            onChanged: (_) => _validate(),
            onSubmitted: (_) => _submit(context),
          );
        },
      ),
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(l10n.createButtonLabel),
            );
          },
        ),
      ],
    );
  }

  Uri? _getNewGroupUri() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    return grouping.buildGroupUri(parentGroupUri, name);
  }

  void _validate() {
    final newGroupUri = _getNewGroupUri();
    final exists = grouping.exists(newGroupUri);
    _isValidNotifier.value = newGroupUri != null && !exists;
    _existsNotifier.value = exists;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_getNewGroupUri());
    }
  }
}
