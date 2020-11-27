import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class TagListPage extends StatelessWidget {
  static const routeName = '/tags';

  final CollectionSource source;

  const TagListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Tuple2<ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple2(s.tagSortFactor, s.pinnedFilters),
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage(
            source: source,
            title: 'Tags',
            chipSetActionDelegate: TagChipSetActionDelegate(source: source),
            chipActionDelegate: ChipActionDelegate(),
            chipActionsBuilder: (filter) => [
              settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
            ],
            filterEntries: _getTagEntries(),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.tag,
              text: 'No tags',
            ),
          ),
        );
      },
    );
  }

  Map<TagFilter, ImageEntry> _getTagEntries() {
    final pinned = settings.pinnedFilters.whereType<TagFilter>();

    final entriesByDate = source.sortedEntriesForFilterList;
    // tags are initially sorted by name at the source level
    var sortedFilters = source.sortedTags.map((tag) => TagFilter(tag));
    if (settings.tagSortFactor == ChipSortFactor.count) {
      final filtersWithCount = List.of(sortedFilters.map((filter) => MapEntry(filter, source.count(filter))));
      filtersWithCount.sort(FilterNavigationPage.compareChipsByEntryCount);
      sortedFilters = filtersWithCount.map((kv) => kv.key).toList();
    }

    final allMapEntries = sortedFilters.map((filter) => MapEntry(
          filter,
          entriesByDate.firstWhere((entry) => entry.xmpSubjects.contains(filter.tag), orElse: () => null),
        ));
    final byPin = groupBy<MapEntry<TagFilter, ImageEntry>, bool>(allMapEntries, (e) => pinned.contains(e.key));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    if (settings.tagSortFactor == ChipSortFactor.date) {
      pinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
      unpinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
    }

    return Map.fromEntries([...pinnedMapEntries, ...unpinnedMapEntries]);
  }
}
