import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagEditorPage extends StatefulWidget {
  static const routeName = '/info/tag_editor';

  final Map<AvesEntry, Set<String>> tagsByEntry;

  const TagEditorPage({
    Key? key,
    required this.tagsByEntry,
  }) : super(key: key);

  @override
  _TagEditorPageState createState() => _TagEditorPageState();
}

class _TagEditorPageState extends State<TagEditorPage> {
  final TextEditingController _newTagTextController = TextEditingController();
  final FocusNode _newTagTextFocusNode = FocusNode();
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);
  late final List<String> _topTags;

  static final List<String> _recentTags = [];

  static const Color untaggedColor = Colors.blueGrey;
  static const int tagHistoryCount = 10;

  Map<AvesEntry, Set<String>> get tagsByEntry => widget.tagsByEntry;

  @override
  void initState() {
    super.initState();
    _initTopTags();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showCount = tagsByEntry.length > 1;
    final Map<String, int> entryCountByTag = {};
    tagsByEntry.entries.forEach((kv) {
      kv.value.forEach((tag) => entryCountByTag[tag] = (entryCountByTag[tag] ?? 0) + 1);
    });
    List<MapEntry<String, int>> sortedTags = _sortEntryCountByTag(entryCountByTag);

    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tagEditorPageTitle),
          actions: [
            IconButton(
              icon: const Icon(AIcons.reset),
              onPressed: _reset,
              tooltip: l10n.resetButtonTooltip,
            ),
          ],
        ),
        body: SafeArea(
          child: ValueListenableBuilder<String?>(
            valueListenable: _expandedSectionNotifier,
            builder: (context, expandedSection, child) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _newTagTextController,
                builder: (context, value, child) {
                  final upQuery = value.text.trim().toUpperCase();
                  bool containQuery(String s) => s.toUpperCase().contains(upQuery);
                  final recentFilters = _recentTags.where(containQuery).map((v) => TagFilter(v)).toList();
                  final topTagFilters = _topTags.where(containQuery).map((v) => TagFilter(v)).toList();
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newTagTextController,
                                focusNode: _newTagTextFocusNode,
                                decoration: InputDecoration(
                                  labelText: l10n.tagEditorPageNewTagFieldLabel,
                                ),
                                autofocus: true,
                                onSubmitted: (newTag) {
                                  _addTag(newTag);
                                  _newTagTextFocusNode.requestFocus();
                                },
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _newTagTextController,
                              builder: (context, value, child) {
                                return IconButton(
                                  icon: const Icon(AIcons.add),
                                  onPressed: value.text.isEmpty ? null : () => _addTag(_newTagTextController.text),
                                  tooltip: l10n.tagEditorPageAddTagTooltip,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: AnimatedCrossFade(
                          firstChild: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: AvesFilterChip.minChipHeight),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(AIcons.tagUntagged, color: untaggedColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.filterTagEmptyLabel,
                                    style: const TextStyle(color: untaggedColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          secondChild: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: sortedTags.map((kv) {
                                final tag = kv.key;
                                return AvesFilterChip(
                                  filter: TagFilter(tag),
                                  removable: true,
                                  showGenericIcon: false,
                                  leadingOverride: showCount ? _TagCount(count: kv.value) : null,
                                  onTap: (filter) => _removeTag(tag),
                                  onLongPress: null,
                                );
                              }).toList(),
                            ),
                          ),
                          crossFadeState: sortedTags.isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: Durations.tagEditorTransition,
                        ),
                      ),
                      const Divider(height: 0),
                      _FilterRow(
                        title: l10n.tagEditorSectionRecent,
                        filters: recentFilters,
                        expandedNotifier: _expandedSectionNotifier,
                        onTap: _addTag,
                      ),
                      _FilterRow(
                        title: l10n.statsTopTags,
                        filters: topTagFilters,
                        expandedNotifier: _expandedSectionNotifier,
                        onTap: _addTag,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _initTopTags() {
    final Map<String, int> entryCountByTag = {};
    final visibleEntries = context.read<CollectionSource?>()?.visibleEntries;
    visibleEntries?.forEach((entry) {
      entry.tags.forEach((tag) => entryCountByTag[tag] = (entryCountByTag[tag] ?? 0) + 1);
    });
    List<MapEntry<String, int>> sortedTopTags = _sortEntryCountByTag(entryCountByTag);
    _topTags = sortedTopTags.map((kv) => kv.key).toList();
  }

  List<MapEntry<String, int>> _sortEntryCountByTag(Map<String, int> entryCountByTag) {
    return entryCountByTag.entries.toList()
      ..sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : compareAsciiUpperCase(kv1.key, kv2.key);
      });
  }

  void _reset() {
    setState(() => tagsByEntry.forEach((entry, tags) {
          tags
            ..clear()
            ..addAll(entry.tags);
        }));
  }

  void _addTag(String newTag) {
    if (newTag.isNotEmpty) {
      setState(() {
        _recentTags
          ..remove(newTag)
          ..insert(0, newTag)
          ..removeRange(min(tagHistoryCount, _recentTags.length), _recentTags.length);
        tagsByEntry.forEach((entry, tags) => tags.add(newTag));
      });
      _newTagTextController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => tagsByEntry.forEach((entry, tags) => tags.remove(tag)));
  }
}

class _FilterRow extends StatelessWidget {
  final String title;
  final List<TagFilter> filters;
  final ValueNotifier<String?> expandedNotifier;
  final void Function(String tag) onTap;

  const _FilterRow({
    Key? key,
    required this.title,
    required this.filters,
    required this.expandedNotifier,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return filters.isEmpty
        ? const SizedBox()
        : ExpandableFilterRow(
            title: title,
            filters: filters,
            expandedNotifier: expandedNotifier,
            showGenericIcon: false,
            onTap: (filter) => onTap((filter as TagFilter).tag),
            onLongPress: null,
          );
  }
}

class _TagCount extends StatelessWidget {
  final int count;

  const _TagCount({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
          color: DefaultTextStyle.of(context).style.color!,
        )),
        borderRadius: const BorderRadius.all(Radius.circular(123)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: AvesFilterChip.fontSize),
      ),
    );
  }
}
