import 'dart:async';
import 'dart:convert';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportCollectionStatsPage extends StatefulWidget {
  static const routeName = '/collection/stats/export';

  final Set<AvesEntry> entries;

  const ExportCollectionStatsPage({
    super.key,
    required this.entries,
  });

  @override
  State<ExportCollectionStatsPage> createState() => _ExportCollectionStatsPageState();
}

class _ExportCollectionStatsPageState extends State<ExportCollectionStatsPage> with FeedbackMixin {
  static const List<ExportableEntryField> _entryFieldOptions = ExportableEntryField.values;
  final Set<ExportableEntryField> _selectedFields = {};
  static const List<String> _exportMimeTypeOptions = [MimeTypes.csv, MimeTypes.json];
  late String _exportMimeType;
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  Set<AvesEntry> get entries => widget.entries;

  AvesEntry get sample => entries.first;

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
    final locale = context.locale;
    final preview = _exportEntryField(field, sample, locale)?.toString() ?? '';
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

  Future<void> _submit(BuildContext context, ExportTarget target) async {
    final mimeType = _exportMimeType;
    final fieldSet = _selectedFields;
    final index = ExportableEntryField.values.indexOf;
    final fieldList = fieldSet.sorted((a, b) => index(a).compareTo(index(b)));

    String content = '';
    switch (mimeType) {
      case MimeTypes.csv:
        content = _exportToCsv(fieldList, context);
      case MimeTypes.json:
        content = _exportToJson(fieldList);
    }

    final bool? success;
    switch (target) {
      case .clipboard:
        try {
          success = await appService.copyToClipboard(text: content);
        } on TooManyItemsException catch (_) {
          await showWarningDialog(
            context: context,
            message: context.l10n.tooManyItemsErrorDialogMessage,
          );
          return;
        }
      case .file:
        final date = DateFormat('yyyyMMdd_HHmmss', kAsciiLocale).format(DateTime.now());
        success = await storageService.createFile(
          basename: 'aves-stats-$date',
          mimeType: mimeType,
          bytes: utf8.encode(content),
        );
    }
    if (success != null) {
      if (success) {
        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
        Navigator.maybeOf(context)?.pop();
      } else {
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }

  String _exportToCsv(List<ExportableEntryField> fields, BuildContext context) {
    final locale = context.locale;
    final headers = fields.map((v) => v.getText(context)).toList();
    List<String> toCsvValues(AvesEntry entry) => fields.map((field) {
      return _exportEntryField(field, entry, locale)?.toString() ?? '';
    }).toList();
    return csv.encode([headers, ...entries.map(toCsvValues)]);
  }

  String _exportToJson(List<ExportableEntryField> fields) {
    final locale = context.locale;
    Map<String, Object?> toJsonMap(AvesEntry entry) => Map.fromEntries(
      fields.map((field) => MapEntry(field.name, _exportEntryField(field, entry, locale))),
    );
    return jsonEncode(entries.map(toJsonMap).toList());
  }

  static Object? _exportEntryField(ExportableEntryField field, AvesEntry entry, String locale) {
    switch (field) {
      case .uri:
        return entry.uri;
      case .path:
        return entry.path;
      case .title:
        return entry.bestTitle;
      case .date:
        return entry.bestDate?.toIso8601String();
      case .size:
        return entry.sizeBytes;
      case .resolution:
        return entry.getResolutionText(locale);
      case .width:
        return entry.displaySize.width.toInt();
      case .height:
        return entry.displaySize.height.toInt();
      case .duration:
        final durationMillis = entry.durationMillis ?? 0;
        return durationMillis > 0 ? durationMillis : null;
      case .coordinates:
        final latLng = entry.latLng;
        return latLng != null ? '${latLng.latitude},${latLng.longitude}' : null;
      case .address:
        final shortAddress = entry.shortAddress;
        return shortAddress.isNotEmpty ? shortAddress : null;
      case .tags:
        return entry.tags.join(';');
    }
  }
}

enum ExportTarget { clipboard, file }
