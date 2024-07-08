import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/expansion_panel.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class RenameEntrySetPage extends StatefulWidget {
  static const routeName = '/rename_entry_set';

  final List<AvesEntry> entries;

  const RenameEntrySetPage({
    super.key,
    required this.entries,
  });

  @override
  State<RenameEntrySetPage> createState() => _RenameEntrySetPageState();
}

class _RenameEntrySetPageState extends State<RenameEntrySetPage> {
  final TextEditingController _patternTextController = TextEditingController();
  final ValueNotifier<NamingPattern> _namingPatternNotifier = ValueNotifier<NamingPattern>(const NamingPattern([]));
  late final String locale;

  static const int previewMax = 10;
  static const double thumbnailExtent = 48;

  List<AvesEntry> get entries => widget.entries;

  int get entryCount => entries.length;

  @override
  void initState() {
    super.initState();
    _patternTextController.text = settings.entryRenamingPattern;
    _patternTextController.addListener(_onUserPatternChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      locale = context.locale;
      _onUserPatternChanged();
    });
  }

  @override
  void dispose() {
    _patternTextController.dispose();
    _namingPatternNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textScaler = MediaQuery.textScalerOf(context);
    final effectiveThumbnailExtent = max(thumbnailExtent, textScaler.scale(thumbnailExtent));
    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);
    return AvesScaffold(
      appBar: AppBar(
        title: Text(l10n.renameEntrySetPageTitle),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _patternTextController,
                      decoration: InputDecoration(
                        labelText: l10n.renameEntrySetPagePatternFieldLabel,
                      ),
                      autofocus: true,
                    ),
                  ),
                  FontSizeIconTheme(
                    child: PopupMenuButton<String>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: NameNamingProcessor.key,
                            child: MenuRow(text: l10n.renameProcessorName, icon: const Icon(AIcons.name)),
                          ),
                          PopupMenuItem(
                            value: CounterNamingProcessor.key,
                            child: MenuRow(text: l10n.renameProcessorCounter, icon: const Icon(AIcons.counter)),
                          ),
                          PopupMenuItem(
                            value: DateNamingProcessor.key,
                            child: MenuRow(text: l10n.viewerInfoLabelDate, icon: const Icon(AIcons.date)),
                          ),
                          PopupMenuItem(
                            value: TagsNamingProcessor.key,
                            child: MenuRow(text: l10n.tagPageTitle, icon: const Icon(AIcons.tag)),
                          ),
                          PopupMenuExpansionPanel<String>(
                            value: MetadataFieldNamingProcessor.key,
                            icon: AIcons.more,
                            title: MaterialLocalizations.of(context).moreButtonTooltip,
                            items: [
                              ...[
                                MetadataField.exifMake,
                                MetadataField.exifModel,
                              ].map((field) => PopupMenuItem(
                                    value: MetadataFieldNamingProcessor.keyWithField(field),
                                    child: MenuRow(text: field.title),
                                  )),
                              PopupMenuItem(
                                value: HashNamingProcessor.key,
                                child: MenuRow(text: l10n.renameProcessorHash),
                              )
                            ],
                          ),
                        ];
                      },
                      onSelected: (key) async {
                        // wait for the popup menu to hide before proceeding with the action
                        await Future.delayed(animations.popUpAnimationDelay * timeDilation);
                        _insertProcessor(key);
                      },
                      tooltip: l10n.renameEntrySetPageInsertTooltip,
                      icon: const Icon(AIcons.add),
                      popUpAnimationStyle: animations.popUpAnimationStyle,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.renameEntrySetPagePreviewSectionTitle,
                style: AStyles.knownTitleText,
              ),
            ),
            Expanded(
              child: GridTheme(
                extent: effectiveThumbnailExtent,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final sourceName = entry.filenameWithoutExtension ?? '';
                    return Row(
                      children: [
                        DecoratedThumbnail(
                          entry: entry,
                          tileExtent: effectiveThumbnailExtent,
                          selectable: false,
                          highlightable: false,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sourceName,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder<NamingPattern>(
                                valueListenable: _namingPatternNotifier,
                                builder: (context, pattern, child) {
                                  return FutureBuilder<String>(
                                    future: pattern.apply(entry, index),
                                    builder: (context, snapshot) {
                                      final info = snapshot.data;
                                      return Text(
                                        info ?? '…',
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: CollectionGrid.fixedExtentLayoutSpacing,
                  ),
                  itemCount: min(entryCount, previewMax),
                ),
              ),
            ),
            const Divider(height: 0),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AvesOutlinedButton(
                  label: l10n.entryActionRename,
                  onPressed: () {
                    settings.entryRenamingPattern = _patternTextController.text;
                    Navigator.maybeOf(context)?.pop<NamingPattern>(_namingPatternNotifier.value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUserPatternChanged() {
    _namingPatternNotifier.value = NamingPattern.from(
      userPattern: _patternTextController.text,
      entryCount: entryCount,
      locale: locale,
    );
  }

  void _insertProcessor(String key) {
    final userPattern = _patternTextController.text;
    final selection = _patternTextController.selection;
    _patternTextController.value = _patternTextController.value.replaced(
      TextRange(
        start: NamingPattern.getInsertionOffset(userPattern, selection.start),
        end: NamingPattern.getInsertionOffset(userPattern, selection.end),
      ),
      NamingPattern.defaultPatternFor(key),
    );
  }
}
