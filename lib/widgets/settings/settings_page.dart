import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aves/model/actions/settings_actions.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/settings/accessibility/accessibility.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:aves/widgets/settings/app_export/selection_dialog.dart';
import 'package:aves/widgets/settings/display/display.dart';
import 'package:aves/widgets/settings/language/language.dart';
import 'package:aves/widgets/settings/navigation/navigation.dart';
import 'package:aves/widgets/settings/privacy/privacy.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/settings_search.dart';
import 'package:aves/widgets/settings/thumbnails/thumbnails.dart';
import 'package:aves/widgets/settings/video/video.dart';
import 'package:aves/widgets/settings/viewer/viewer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with FeedbackMixin {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

  static final List<SettingsSection> sections = [
    NavigationSection(),
    ThumbnailsSection(),
    ViewerSection(),
    VideoSection(),
    PrivacySection(),
    AccessibilitySection(),
    DisplaySection(),
    LanguageSection(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durations = context.watch<DurationsData>();
    return MediaQueryDataProvider(
      child: Scaffold(
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
            MenuIconTheme(
              child: PopupMenuButton<SettingsAction>(
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
            ),
          ],
        ),
        body: GestureAreaProtectorStack(
          child: SafeArea(
            bottom: false,
            child: Theme(
              data: theme.copyWith(
                textTheme: theme.textTheme.copyWith(
                  // dense style font for tile subtitles, without modifying title font
                  bodyMedium: const TextStyle(fontSize: 12),
                ),
              ),
              child: AnimationLimiter(
                child: Selector<MediaQueryData, double>(
                    selector: (context, mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom),
                    builder: (context, mqPaddingBottom, child) {
                      return ListView(
                        padding: const EdgeInsets.all(8) + EdgeInsets.only(bottom: mqPaddingBottom),
                        children: AnimationConfiguration.toStaggeredList(
                          duration: durations.staggeredAnimation,
                          delay: durations.staggeredAnimationDelay * timeDilation,
                          childAnimationBuilder: (child) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: child,
                            ),
                          ),
                          children: sections.map((v) => v.build(context, _expandedNotifier)).toList(),
                        ),
                      );
                    }),
              ),
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
        break;
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
              // backwards compatibility before versioning
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
        break;
    }
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: SettingsSearchDelegate(
          searchFieldLabel: context.l10n.settingsSearchFieldLabel,
          sections: sections,
        ),
      ),
    );
  }
}
