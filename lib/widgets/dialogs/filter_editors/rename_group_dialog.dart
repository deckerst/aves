import 'package:aves/model/grouping/common.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class RenameGroupDialog extends StatefulWidget {
  static const routeName = '/dialog/rename_group';

  final FilterGrouping grouping;
  final Uri groupUri;

  const RenameGroupDialog({
    super.key,
    required this.grouping,
    required this.groupUri,
  });

  @override
  State<RenameGroupDialog> createState() => _RenameGroupDialogState();
}

class _RenameGroupDialogState extends State<RenameGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  FilterGrouping get grouping => widget.grouping;

  Uri get initialGroupUri => widget.groupUri;

  Uri? get parentGroupUri => FilterGrouping.getParentGroup(initialGroupUri);

  @override
  void initState() {
    super.initState();
    _nameController.text = FilterGrouping.getGroupName(initialGroupUri) ?? '';
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
      content: ValueListenableBuilder<bool>(
        valueListenable: _existsNotifier,
        builder: (context, exists, child) {
          return TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.renameAlbumDialogLabel,
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
              child: Text(l10n.applyButtonLabel),
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
    _existsNotifier.value = exists && newGroupUri != initialGroupUri;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_getNewGroupUri());
    }
  }
}
