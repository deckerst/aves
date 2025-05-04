import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/placeholder.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagEditorPage extends StatefulWidget {
  static const routeName = '/info/tag_editor';

  final Map<AvesEntry, Set<TagFilter>> tagsByEntry;

  const TagEditorPage({
    super.key,
    required this.tagsByEntry,
  });

  @override
  State<TagEditorPage> createState() => _TagEditorPageState();
}

class _TagEditorPageState extends State<TagEditorPage> {
  final TextEditingController _newTagTextController = TextEditingController();
  final FocusNode _newTagTextFocusNode = FocusNode();
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);
  late final Map<AvesEntry, Set<CollectionFilter>> filtersByEntry;
  late final List<CollectionFilter> _topTags;
  final List<CollectionFilter> _userAddedFilters = [];

  static final List<PlaceholderFilter> _placeholders = [
    PlaceholderFilter.country,
    PlaceholderFilter.state,
    PlaceholderFilter.place,
  ];

  @override
  void initState() {
    super.initState();
    filtersByEntry = widget.tagsByEntry.map((key, value) => MapEntry(key, value.cast<CollectionFilter>().toSet()));
    _expandedSectionNotifier.value = settings.tagEditorExpandedSection;
    _expandedSectionNotifier.addListener(() => settings.tagEditorExpandedSection = _expandedSectionNotifier.value);
    _initTopTags();
  }

  @override
  void dispose() {
    _newTagTextController.dispose();
    _newTagTextFocusNode.dispose();
    _expandedSectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showCount = filtersByEntry.length > 1;
    final Map<CollectionFilter, int> entryCountByTag = {};
    filtersByEntry.entries.forEach((kv) {
      kv.value.forEach((tag) => entryCountByTag[tag] = (entryCountByTag[tag] ?? 0) + 1);
    });
    List<MapEntry<CollectionFilter, int>> sortedTags = _sortCurrentTags(entryCountByTag);

    final untaggedColor = Themes.backgroundTextColor(context);

    return PopScope(
      canPop: !_isModified,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final NavigatorState navigator = Navigator.of(context);
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AvesDialog(
                content: Text(context.l10n.tagEditorDiscardDialogMessage),
                actions: [
                  const CancelButton(),
                  TextButton(
                    onPressed: () => Navigator.maybeOf(context)?.pop(true),
                    child: Text(Themes.asButtonLabel(MaterialLocalizations.of(context).okButtonLabel)),
                  ),
                ],
              ),
              routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
            ) ??
            false;
        if (confirmed) {
          navigator.pop();
        }
      },
      child: AvesScaffold(
        appBar: AppBar(
          title: Text(l10n.tagEditorPageTitle),
          actions: [
            IconButton(
              icon: const Icon(AIcons.reset),
              onPressed: _reset,
              tooltip: l10n.resetTooltip,
            ),
            IconButton(
              icon: const Icon(AIcons.apply),
              onPressed: () => Navigator.maybeOf(context)?.pop(filtersByEntry),
              tooltip: l10n.saveTooltip,
            ),
            const SizedBox(width: 16),
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
                  final recentFilters = settings.recentTags.where(containQuery).toList();
                  final topTagFilters = _topTags.where(containQuery).toList();
                  final placeholderFilters = _placeholders.where(containQuery).toList();
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
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
                                  onPressed: value.text.trim().isEmpty ? null : () => _addCustomTag(_newTagTextController.text),
                                  tooltip: l10n.tagEditorPageAddTagTooltip,
                                );
                              },
                            ),
                            Selector<Settings, bool>(
                              selector: (context, s) => s.tagEditorCurrentFilterSectionExpanded,
                              builder: (context, isExpanded, child) {
                                return IconButton(
                                  icon: Icon(isExpanded ? AIcons.collapse : AIcons.expand),
                                  onPressed: sortedTags.isEmpty ? null : () => settings.tagEditorCurrentFilterSectionExpanded = !isExpanded,
                                  tooltip: isExpanded ? MaterialLocalizations.of(context).expandedIconTapHint : MaterialLocalizations.of(context).collapsedIconTapHint,
                                );
                              },
                            ),
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
                                  Icon(AIcons.tagUntagged, color: untaggedColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.filterNoTagLabel,
                                    style: TextStyle(color: untaggedColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          secondChild: ExpandableFilterRow(
                            filters: sortedTags.map((kv) => kv.key).toList(),
                            isExpanded: context.select<Settings, bool>((v) => v.tagEditorCurrentFilterSectionExpanded),
                            showGenericIcon: false,
                            leadingBuilder: showCount
                                ? (filter) => _TagCount(
                                      count: sortedTags.firstWhere((kv) => kv.key == filter).value,
                                    )
                                : null,
                            onTap: (filter) {
                              if (filtersByEntry.keys.length > 1) {
                                // for multiple entries, set tag for all of them
                                filtersByEntry.forEach((entry, filters) => filters.add(filter));
                                setState(() {});
                              } else {
                                // for single entry, remove tag (like pressing on the remove icon)
                                _removeTag(filter);
                              }
                            },
                            onRemove: _removeTag,
                            onLongPress: null,
                          ),
                          crossFadeState: sortedTags.isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: ADurations.tagEditorTransition,
                        ),
                      ),
                      const Divider(height: 0),
                      _FilterRow(
                        title: l10n.statsTopTagsSectionTitle,
                        filters: topTagFilters,
                        expandedNotifier: _expandedSectionNotifier,
                        onTap: _addTag,
                      ),
                      _FilterRow(
                        title: l10n.tagEditorSectionRecent,
                        filters: recentFilters,
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
    List<MapEntry<CollectionFilter, int>> sortedTopTags = _sortCurrentTags(entryCountByTag.map((key, value) => MapEntry(TagFilter(key), value)));
    _topTags = sortedTopTags.map((kv) => kv.key).toList();
  }

  List<MapEntry<CollectionFilter, int>> _sortCurrentTags(Map<CollectionFilter, int> entryCountByTag) {
    return entryCountByTag.entries.toList()
      ..sort((kv1, kv2) {
        final filter1 = kv1.key;
        final filter2 = kv2.key;

        final recent1 = _userAddedFilters.indexOf(filter1);
        final recent2 = _userAddedFilters.indexOf(filter2);
        var c = recent2.compareTo(recent1);
        if (c != 0) return c;

        final count1 = kv1.value;
        final count2 = kv2.value;
        c = count2.compareTo(count1);
        if (c != 0) return c;

        return filter1.compareTo(filter2);
      });
  }

  bool get _isModified {
    for (final kv in filtersByEntry.entries) {
      final oldFilters = kv.key.tags.map(TagFilter.new).toSet();
      final newFilters = kv.value;
      if (newFilters.length != oldFilters.length || !newFilters.containsAll(oldFilters)) return true;
    }
    return false;
  }

  void _reset() {
    _userAddedFilters.clear();
    filtersByEntry.forEach((entry, tags) {
      final originalFilters = entry.tags.map(TagFilter.new).toSet();
      tags
        ..clear()
        ..addAll(originalFilters);
    });
    setState(() {});
  }

  void _addCustomTag(String newTag) {
    newTag = newTag.trim();
    if (newTag.isNotEmpty) {
      _addTag(TagFilter(newTag));
    }
  }

  void _addTag(CollectionFilter filter) {
    settings.recentTags = settings.recentTags
      ..remove(filter)
      ..insert(0, filter);
    _userAddedFilters
      ..remove(filter)
      ..add(filter);
    filtersByEntry.forEach((entry, tags) => tags.add(filter));
    _newTagTextController.clear();
    setState(() {});
  }

  void _removeTag(CollectionFilter filter) {
    _userAddedFilters.remove(filter);
    filtersByEntry.forEach((entry, filters) => filters.remove(filter));
    setState(() {});
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
        : TitledExpandableFilterRow(
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
