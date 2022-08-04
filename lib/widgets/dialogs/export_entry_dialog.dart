import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class ExportEntryDialog extends StatefulWidget {
  final AvesEntry entry;

  const ExportEntryDialog({
    super.key,
    required this.entry,
  });

  @override
  State<ExportEntryDialog> createState() => _ExportEntryDialogState();
}

class _ExportEntryDialogState extends State<ExportEntryDialog> {
  final TextEditingController _widthController = TextEditingController(), _heightController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  String _mimeType = MimeTypes.jpeg;

  AvesEntry get entry => widget.entry;

  static const imageExportFormats = [
    MimeTypes.bmp,
    MimeTypes.jpeg,
    MimeTypes.png,
    MimeTypes.webp,
  ];

  @override
  void initState() {
    super.initState();
    _widthController.text = '${entry.isRotated ? entry.height : entry.width}';
    _heightController.text = '${entry.isRotated ? entry.width : entry.height}';
    _validate();
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const contentHorizontalPadding = EdgeInsets.symmetric(horizontal: AvesDialog.defaultHorizontalContentPadding);

    return AvesDialog(
      scrollableContent: [
        const SizedBox(height: 16),
        Padding(
          padding: contentHorizontalPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.exportEntryDialogFormat),
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
        ),
        Padding(
          padding: contentHorizontalPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  decoration: InputDecoration(labelText: l10n.exportEntryDialogWidth),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final width = int.tryParse(value);
                    _heightController.text = width != null ? '${(width / entry.displayAspectRatio).round()}' : '';
                    _validate();
                  },
                ),
              ),
              const Text(AvesEntry.resolutionSeparator),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: l10n.exportEntryDialogHeight),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final height = int.tryParse(value);
                    _widthController.text = height != null ? '${(height * entry.displayAspectRatio).round()}' : '';
                    _validate();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid
                  ? () {
                      final width = int.tryParse(_widthController.text);
                      final height = int.tryParse(_heightController.text);
                      final options = (width != null && height != null)
                          ? EntryExportOptions(
                              mimeType: _mimeType,
                              width: width,
                              height: height,
                            )
                          : null;
                      Navigator.pop(context, options);
                    }
                  : null,
              child: Text(l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  Future<void> _validate() async {
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    _isValidNotifier.value = (width ?? 0) > 0 && (height ?? 0) > 0;
  }
}
