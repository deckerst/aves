import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class ExportEntryDialog extends StatefulWidget {
  final AvesEntry entry;

  const ExportEntryDialog({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  _ExportEntryDialogState createState() => _ExportEntryDialogState();
}

class _ExportEntryDialogState extends State<ExportEntryDialog> {
  String _mimeType = MimeTypes.jpeg;

  AvesEntry get entry => widget.entry;

  static const imageExportFormats = [
    MimeTypes.bmp,
    MimeTypes.jpeg,
    MimeTypes.png,
    MimeTypes.webp,
  ];

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      context: context,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.exportEntryDialogFormat),
          const SizedBox(width: AvesDialog.controlCaptionPadding),
          DropdownButton<String>(
            items: imageExportFormats.map((mimeType) {
              return DropdownMenuItem<String>(
                value: mimeType,
                child: Text(MimeUtils.displayType(mimeType)),
              );
            }).toList(),
            value: _mimeType,
            onChanged: (selected) {
              if (selected != null) {
                setState(() => _mimeType = selected);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _mimeType),
          child: Text(context.l10n.applyButtonLabel),
        )
      ],
    );
  }
}
