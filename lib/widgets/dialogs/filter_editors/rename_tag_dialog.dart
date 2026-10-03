import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:material_ui/material_ui.dart';

class const RenameTagDialog({
  super.key,
  required final String tag,
  required final Set<String> collectionTags,
}) extends StatefulWidget {
  static const routeName = '/dialog/rename_tag';

  @override
  State<RenameTagDialog> createState() => _RenameTagDialogState();
}

class _RenameTagDialogState extends State<RenameTagDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  String get initialValue => widget.tag;

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
              helperText: exists ? context.l10n.renameTagDialogLabelAlreadyExistsHelper : '',
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
              child: Text(context.l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  Future<void> _validate() async {
    final newName = _nameController.text.trim();
    final exists = newName.isNotEmpty && widget.collectionTags.contains(newName);
    _existsNotifier.value = exists && newName != initialValue;
    // do not allow existing target
    _isValidNotifier.value = (!exists || newName == initialValue) && newName.isNotEmpty;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop<String>(_nameController.text);
    }
  }
}
