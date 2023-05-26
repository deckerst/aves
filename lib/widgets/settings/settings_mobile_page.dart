import 'dart:convert';
import 'dart:typed_data';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:aves/widgets/settings/app_export/selection_dialog.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:aves/widgets/settings/settings_search.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsMobilePage extends StatefulWidget {
  const SettingsMobilePage({super.key});

  @override
  State<SettingsMobilePage> createState() => _SettingsMobilePageState();
}

class _SettingsMobilePageState extends State<SettingsMobilePage> with FeedbackMixin {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _expandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        title: InteractiveAppBarTitle(
          onTap: () => _goToSearch(context),
          child: Text(context.l10n.settingsPageTitle),
        ),
        actions: [
          IconButton(
            icon: const Icon(AIcons.search),
            onPressed: () => _goToSearch(context),
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
          ),
          PopupMenuButton<SettingsAction>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: SettingsAction.export,
                  child: MenuRow(text: context.l10n.settingsActionExport, icon: const Icon(AIcons.fileExport)),
                ),
                PopupMenuItem(
                  value: SettingsAction.import,
                  child: MenuRow(text: context.l10n.settingsActionImport, icon: const Icon(AIcons.fileImport)),
                ),
              ];
            },
            onSelected: (action) async {
              // wait for the popup menu to hide before proceeding with the action
              await Future.delayed(Durations.popupMenuAnimation * timeDilation);
              _onActionSelected(action);
            },
          ),
        ].map((v) => FontSizeIconTheme(child: v)).toList(),
      ),
      body: GestureAreaProtectorStack(
        child: SafeArea(
          bottom: false,
          child: AnimationLimiter(
            child: SettingsListView(
              children: SettingsPage.sections.map((v) => v.build(context, _expandedNotifier)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  static const String exportVersionKey = 'version';
  static const int exportVersion = 1;

  void _onActionSelected(SettingsAction action) async {
    final source = context.read<CollectionSource>();
    switch (action) {
      case SettingsAction.export:
        final toExport = await showDialog<Set<AppExportItem>>(
          context: context,
          builder: (context) => AppExportItemSelectionDialog(
            title: context.l10n.settingsActionExportDialogTitle,
          ),
        );
        if (toExport == null || toExport.isEmpty) return;

        final allMap = Map.fromEntries(toExport.map((v) {
          final jsonMap = v.export(source);
          return jsonMap != null ? MapEntry(v.name, jsonMap) : null;
        }).whereNotNull());
        allMap[exportVersionKey] = exportVersion;
        final allJsonString = jsonEncode(allMap);

        final success = await storageService.createFile(
          'aves-settings-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
          MimeTypes.json,
          Uint8List.fromList(utf8.encode(allJsonString)),
        );
        if (success != null) {
          if (success) {
            showFeedback(context, context.l10n.genericSuccessFeedback);
          } else {
            showFeedback(context, context.l10n.genericFailureFeedback);
          }
        }
      case SettingsAction.import:
        // specifying the JSON MIME type to restrict openable files is correct in theory,
        // but older devices (e.g. SM-P580, API 27) that do not recognize JSON files as such would filter them out
        final bytes = await storageService.openFile();
        if (bytes.isNotEmpty) {
          try {
            final allJsonString = utf8.decode(bytes);
            final allJsonMap = jsonDecode(allJsonString);

            final version = allJsonMap[exportVersionKey];
            final importable = <AppExportItem, dynamic>{};
            if (version == null) {
              // backward compatibility before versioning
              importable[AppExportItem.settings] = allJsonMap;
            } else {
              if (allJsonMap is! Map) {
                debugPrint('failed to import app json=$allJsonMap');
                showFeedback(context, context.l10n.genericFailureFeedback);
                return;
              }
              allJsonMap.keys.where((v) => v != exportVersionKey).forEach((k) {
                try {
                  importable[AppExportItem.values.byName(k)] = allJsonMap[k];
                } catch (error, stack) {
                  debugPrint('failed to identify import app item=$k with error=$error\n$stack');
                }
              });
            }

            final toImport = await showDialog<Set<AppExportItem>>(
              context: context,
              builder: (context) => AppExportItemSelectionDialog(
                title: context.l10n.settingsActionImportDialogTitle,
                selectableItems: importable.keys.toSet(),
              ),
            );
            if (toImport == null || toImport.isEmpty) return;

            await Future.forEach<AppExportItem>(toImport, (item) async {
              return item.import(importable[item], source);
            });
            showFeedback(context, context.l10n.genericSuccessFeedback);
          } catch (error) {
            debugPrint('failed to import app json, error=$error');
            showFeedback(context, context.l10n.genericFailureFeedback);
          }
        }
    }
  }

  void _goToSearch(BuildContext context) {
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: SettingsSearchDelegate(
          searchFieldLabel: context.l10n.settingsSearchFieldLabel,
          sections: SettingsPage.sections,
        ),
      ),
    );
  }
}
