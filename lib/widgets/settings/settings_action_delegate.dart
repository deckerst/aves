import 'dart:convert';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:aves/widgets/settings/app_export/selection_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsActionDelegate with FeedbackMixin {
  static const String _exportVersionKey = 'version';
  static const int _exportVersion = 1;

  void onActionSelected(BuildContext context, SettingsAction action) {
    switch (action) {
      case .export:
        _export(context);
      case .import:
        _import(context);
    }
  }

  static Uint8List getExportContent({
    required CollectionSource source,
    required Set<AppExportItem> toExport,
  }) {
    final allMap = Map.fromEntries(
      toExport.map((v) {
        final jsonMap = v.export(source);
        return jsonMap != null ? MapEntry(v.name, jsonMap) : null;
      }).nonNulls,
    );
    allMap[_exportVersionKey] = _exportVersion;
    final jsonContent = const JsonEncoder.withIndent('  ').convert(allMap);
    return utf8.encode(jsonContent);
  }

  Future<void> _export(BuildContext context) async {
    final l10n = context.l10n;
    final toExport = await showDialog<Set<AppExportItem>>(
      context: context,
      builder: (context) => AppExportItemSelectionDialog(
        title: l10n.settingsActionExportDialogTitle,
      ),
    );
    if (toExport == null || toExport.isEmpty) return;

    final date = DateFormat('yyyyMMdd_HHmmss', kAsciiLocale).format(DateTime.now());
    final content = getExportContent(
      source: context.read<CollectionSource>(),
      toExport: toExport,
    );
    const mimeType = MimeTypes.json;
    final success = await storageService.createFile(
      basename: 'aves-settings-$date',
      mimeType: mimeType,
      bytes: content,
    );

    if (success != null) {
      if (success) {
        showFeedback(context, FeedbackType.info, l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, FeedbackType.warn, l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _import(BuildContext context) async {
    final l10n = context.l10n;
    // specifying the JSON MIME type to restrict openable files is correct in theory,
    // but older devices (e.g. SM-P580, API 27) that do not recognize JSON files as such would filter them out
    final bytes = await storageService.openFile();
    if (bytes.isNotEmpty) {
      try {
        final allJsonString = utf8.decode(bytes);
        final allJsonMap = jsonDecode(allJsonString) as Map<String, Object?>;

        final version = allJsonMap[_exportVersionKey] as int?;
        final importable = <AppExportItem, Object>{};
        if (version == null) {
          // backward compatibility before versioning
          importable[AppExportItem.settings] = allJsonMap;
        } else {
          allJsonMap.keys.where((v) => v != _exportVersionKey).forEach((k) {
            try {
              importable[AppExportItem.values.byName(k)] = allJsonMap[k] as Object;
            } catch (error, stack) {
              debugPrint('failed to identify import app item=$k with error=$error\n$stack');
            }
          });
        }

        final toImport = await showDialog<Set<AppExportItem>>(
          context: context,
          builder: (context) => AppExportItemSelectionDialog(
            title: l10n.settingsActionImportDialogTitle,
            selectableItems: importable.keys.toSet(),
          ),
        );
        if (toImport == null || toImport.isEmpty) return;

        final source = context.read<CollectionSource>();
        await Future.forEach<AppExportItem>(toImport, (item) async {
          final jsonObject = importable[item];
          if (jsonObject != null) {
            await item.import(jsonObject, source);
          }
        });
        showFeedback(context, FeedbackType.info, l10n.genericSuccessFeedback);
      } catch (error, stack) {
        debugPrint('failed to import app json, error=$error\n$stack');
        showFeedback(context, FeedbackType.warn, l10n.genericFailureFeedback);
      }
    }
  }
}
