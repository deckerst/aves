import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class EditEntryDescriptionDialog extends StatefulWidget {
  final String initialDescription;

  const EditEntryDescriptionDialog({
    super.key,
    required this.initialDescription,
  });

  @override
  State<EditEntryDescriptionDialog> createState() => _EditEntryDescriptionDialogState();
}

class _EditEntryDescriptionDialogState extends State<EditEntryDescriptionDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialDescription);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(builder: (context) {
        final l10n = context.l10n;

        return AvesDialog(
          title: l10n.editEntryDescriptionDialogTitle,
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => _submit(context),
              child: Text(l10n.applyButtonLabel),
            ),
          ],
        );
      }),
    );
  }

  void _submit(BuildContext context) => Navigator.pop(context, _textController.text);
}
