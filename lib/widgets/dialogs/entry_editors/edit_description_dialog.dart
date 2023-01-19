import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/widgets/common/basic/labeled_checkbox.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class EditEntryTitleDescriptionDialog extends StatefulWidget {
  final String initialTitle, initialDescription;

  const EditEntryTitleDescriptionDialog({
    super.key,
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  State<EditEntryTitleDescriptionDialog> createState() => _EditEntryTitleDescriptionDialogState();
}

class _EditEntryTitleDescriptionDialogState extends State<EditEntryTitleDescriptionDialog> {
  final Set<DescriptionField> fields = {
    DescriptionField.title,
    DescriptionField.description,
  };
  late final TextEditingController _titleTextController, _descriptionTextController;

  @override
  void initState() {
    super.initState();
    _titleTextController = TextEditingController(text: widget.initialTitle);
    _descriptionTextController = TextEditingController(text: widget.initialDescription);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(builder: (context) {
        return AvesDialog(
          scrollableContent: [
            const SizedBox(height: 8),
            ..._buildFieldEditor(DescriptionField.title),
            ..._buildFieldEditor(DescriptionField.description),
            const SizedBox(height: 8),
          ],
          actions: [
            const CancelButton(),
            TextButton(
              onPressed: fields.isEmpty ? null : () => _submit(context),
              child: Text(context.l10n.applyButtonLabel),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildFieldEditor(DescriptionField field) {
    final editing = fields.contains(field);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LabeledCheckbox(
          value: editing,
          onChanged: (v) => setState(() => editing ? fields.remove(field) : fields.add(field)),
          text: _fieldName(field),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: _fieldController(field),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLines: null,
          enabled: editing,
        ),
      ),
    ];
  }

  TextEditingController _fieldController(DescriptionField field) {
    switch (field) {
      case DescriptionField.title:
        return _titleTextController;
      case DescriptionField.description:
        return _descriptionTextController;
    }
  }

  String _fieldName(DescriptionField field) {
    switch (field) {
      case DescriptionField.title:
        return context.l10n.viewerInfoLabelTitle;
      case DescriptionField.description:
        return context.l10n.viewerInfoLabelDescription;
    }
  }

  void _submit(BuildContext context) {
    final modifier = Map.fromEntries(fields.map((field) {
      final text = _fieldController(field).text;
      return MapEntry(field, text.isEmpty ? null : text);
    }));
    return Navigator.maybeOf(context)?.pop<Map<DescriptionField, String?>>(modifier);
  }
}
