import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/buttons.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
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

  static const int previewMax = 10;
  static const double thumbnailExtent = 48;

  List<AvesEntry> get entries => widget.entries;

  int get entryCount => entries.length;

  @override
  void initState() {
    super.initState();
    _patternTextController.text = settings.entryRenamingPattern;
    _patternTextController.addListener(_onUserPatternChange);
    _onUserPatternChange();
  }

  @override
  void dispose() {
    _patternTextController.removeListener(_onUserPatternChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MediaQueryDataProvider(
      child: Scaffold(
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
                    MenuIconTheme(
                      child: PopupMenuButton<String>(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: DateNamingProcessor.key,
                              child: MenuRow(text: l10n.viewerInfoLabelDate, icon: const Icon(AIcons.date)),
                            ),
                            PopupMenuItem(
                              value: NameNamingProcessor.key,
                              child: MenuRow(text: l10n.renameProcessorName, icon: const Icon(AIcons.name)),
                            ),
                            PopupMenuItem(
                              value: CounterNamingProcessor.key,
                              child: MenuRow(text: l10n.renameProcessorCounter, icon: const Icon(AIcons.counter)),
                            ),
                          ];
                        },
                        onSelected: (key) async {
                          // wait for the popup menu to hide before proceeding with the action
                          await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                          _insertProcessor(key);
                        },
                        tooltip: l10n.renameEntrySetPageInsertTooltip,
                        icon: const Icon(AIcons.add),
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
                  style: Constants.knownTitleTextStyle,
                ),
              ),
              Expanded(
                child: Selector<MediaQueryData, double>(
                    selector: (context, mq) => mq.textScaleFactor,
                    builder: (context, textScaleFactor, child) {
                      final effectiveThumbnailExtent = max(thumbnailExtent, thumbnailExtent * textScaleFactor);
                      return GridTheme(
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
                                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      ValueListenableBuilder<NamingPattern>(
                                        valueListenable: _namingPatternNotifier,
                                        builder: (context, pattern, child) {
                                          return Text(
                                            pattern.apply(entry, index),
                                            softWrap: false,
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
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
                      );
                    }),
              ),
              const Divider(height: 0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AvesOutlinedButton(
                    label: l10n.entryActionRename,
                    onPressed: () {
                      settings.entryRenamingPattern = _patternTextController.text;
                      Navigator.pop<NamingPattern>(context, _namingPatternNotifier.value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onUserPatternChange() {
    _namingPatternNotifier.value = NamingPattern.from(
      userPattern: _patternTextController.text,
      entryCount: entryCount,
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
