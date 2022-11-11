import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/placeholder.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagEditorPage extends StatefulWidget {
  static const routeName = '/info/tag_editor';

  final Map<AvesEntry, Set<CollectionFilter>> filtersByEntry;

  const TagEditorPage({
    super.key,
    required this.filtersByEntry,
  });

  @override
  State<TagEditorPage> createState() => _TagEditorPageState();
}

class _TagEditorPageState extends State<TagEditorPage> {
  final TextEditingController _newTagTextController = TextEditingController();
  final FocusNode _newTagTextFocusNode = FocusNode();
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);
  late final List<CollectionFilter> _topTags;
  late final List<PlaceholderFilter> _placeholders = [PlaceholderFilter.country, PlaceholderFilter.place];

  static final List<CollectionFilter> _recentTags = [];

  static const Color untaggedColor = Colors.blueGrey;
  static const int tagHistoryCount = 10;

  Map<AvesEntry, Set<CollectionFilter>> get tagsByEntry => widget.filtersByEntry;

  @override
  void initState() {
    super.initState();
    _initTopTags();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showCount = tagsByEntry.length > 1;
    final Map<CollectionFilter, int> entryCountByTag = {};
    tagsByEntry.entries.forEach((kv) {
      kv.value.forEach((tag) => entryCountByTag[tag] = (entryCountByTag[tag] ?? 0) + 1);
    });
    List<MapEntry<CollectionFilter, int>> sortedTags = _sortEntryCountByTag(entryCountByTag);

    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tagEditorPageTitle),
          actions: [
            IconButton(
              icon: const Icon(AIcons.reset),
              onPressed: _reset,
              tooltip: l10n.resetTooltip,
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
                  bool containQuery(CollectionFilter v) => v.getLabel(context).toUpperCase().contains(upQuery);
                  final recentFilters = _recentTags.where(containQuery).toList();
                  final topTagFilters = _topTags.where(containQuery).toList();
                  final placeholderFilters = _placeholders.where(containQuery).toList();
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
                                  _addCustomTag(newTag);
                                  _newTagTextFocusNode.requestFocus();
                                },
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _newTagTextController,
                              builder: (context, value, child) {
                                return IconButton(
                                  icon: const Icon(AIcons.add),
                                  onPressed: value.text.isEmpty ? null : () => _addCustomTag(_newTagTextController.text),
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
                                    l10n.filterNoTagLabel,
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
                                return AvesFilterChip(
                                  filter: kv.key,
                                  removable: true,
                                  showGenericIcon: false,
                                  leadingOverride: showCount ? _TagCount(count: kv.value) : null,
                                  onTap: _removeTag,
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
                        title: l10n.statsTopTagsSectionTitle,
                        filters: topTagFilters,
                        expandedNotifier: _expandedSectionNotifier,
                        onTap: _addTag,
                      ),
                      _FilterRow(
                        title: l10n.tagEditorSectionPlaceholders,
                        filters: placeholderFilters,
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
    List<MapEntry<CollectionFilter, int>> sortedTopTags = _sortEntryCountByTag(entryCountByTag.map((key, value) => MapEntry(TagFilter(key), value)));
    _topTags = sortedTopTags.map((kv) => kv.key).toList();
  }

  List<MapEntry<CollectionFilter, int>> _sortEntryCountByTag(Map<CollectionFilter, int> entryCountByTag) {
    return entryCountByTag.entries.toList()
      ..sort((kv1, kv2) {
        final c = kv2.value.compareTo(kv1.value);
        return c != 0 ? c : kv1.key.compareTo(kv2.key);
      });
  }

  void _reset() {
    setState(() => tagsByEntry.forEach((entry, tags) {
          final Set<TagFilter> originalFilters = entry.tags.map(TagFilter.new).toSet();
          tags
            ..clear()
            ..addAll(originalFilters);
        }));
  }

  void _addCustomTag(String newTag) {
    if (newTag.isNotEmpty) {
      _addTag(TagFilter(newTag));
    }
  }

  void _addTag(CollectionFilter newTag) {
    setState(() {
      _recentTags
        ..remove(newTag)
        ..insert(0, newTag)
        ..removeRange(min(tagHistoryCount, _recentTags.length), _recentTags.length);
      tagsByEntry.forEach((entry, tags) => tags.add(newTag));
    });
    _newTagTextController.clear();
  }

  void _removeTag(CollectionFilter filter) {
    setState(() => tagsByEntry.forEach((entry, filters) => filters.remove(filter)));
  }
}

class _FilterRow extends StatelessWidget {
  final String title;
  final List<CollectionFilter> filters;
  final ValueNotifier<String?> expandedNotifier;
  final void Function(CollectionFilter filter) onTap;

  const _FilterRow({
    required this.title,
    required this.filters,
    required this.expandedNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return filters.isEmpty
        ? const SizedBox()
        : ExpandableFilterRow(
            title: title,
            filters: filters,
            expandedNotifier: expandedNotifier,
            showGenericIcon: false,
            onTap: onTap,
            onLongPress: null,
          );
  }
}

class _TagCount extends StatelessWidget {
  final int count;

  const _TagCount({
    required this.count,
  });

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
