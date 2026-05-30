import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/view/src/metadata/exportable_fields.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class ExportCollectionStatsPage extends StatefulWidget {
  static const routeName = '/collection/stats/export';

  final String Function(ExportableEntryField field) previewer;

  const ExportCollectionStatsPage({
    super.key,
    required this.previewer,
  });

  @override
  State<ExportCollectionStatsPage> createState() => _ExportCollectionStatsPageState();
}

class _ExportCollectionStatsPageState extends State<ExportCollectionStatsPage> {
  static const List<ExportableEntryField> _entryFieldOptions = ExportableEntryField.values;
  final Set<ExportableEntryField> _selectedFields = {};
  static const List<String> _exportMimeTypeOptions = [MimeTypes.csv, MimeTypes.json];
  late String _exportMimeType;
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _exportMimeType = MimeTypes.csv;
    _validate();
  }

  @override
  void dispose() {
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesScaffold(
      appBar: AppBar(
        title: Text(l10n.settingsActionExport),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: ListView(
                children: _entryFieldOptions.map(_toTile).toList(),
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Text(l10n.exportEntryDialogFormat),
                  const SizedBox(width: 16),
                  TextDropdownButton<String>(
                    values: _exportMimeTypeOptions,
                    valueText: MimeUtils.displayType,
                    value: _exportMimeType,
                    onChanged: (v) {
                      _exportMimeType = v!;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return Wrap(
                    alignment: .end,
                    spacing: 16,
                    children: [
                      AvesOutlinedButton(
                        label: context.l10n.entryActionCopyToClipboard,
                        onPressed: isValid ? () => _submit(context, ExportTarget.clipboard) : null,
                      ),
                      AvesOutlinedButton(
                        label: context.l10n.saveTooltip,
                        onPressed: isValid ? () => _submit(context, ExportTarget.file) : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toTile(ExportableEntryField field) {
    final preview = widget.previewer(field);
    return SwitchListTile(
      value: _selectedFields.contains(field),
      subtitle: preview.isNotEmpty ? Text(preview) : null,
      onChanged: (selected) {
        selected ? _selectedFields.add(field) : _selectedFields.remove(field);
        setState(_validate);
      },
      title: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedText(
          textSpans: [
            TextSpan(
              text: field.getText(context),
              style: TextStyle(
                shadows: HighlightTitle.shadows(context),
              ),
            ),
          ],
          outlineColor: Themes.firstLayerColor(context),
        ),
      ),
    );
  }

  void _validate() => _isValidNotifier.value = _selectedFields.isNotEmpty;

  void _submit(BuildContext context, ExportTarget target) => Navigator.maybeOf(context)?.pop((_exportMimeType, _selectedFields, target));
}

enum ExportTarget { clipboard, file }
