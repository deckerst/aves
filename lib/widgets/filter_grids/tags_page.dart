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
            filterBuilder: _buildFilter,
            emptyBuilder: () => EmptyContent(
              icon: AIcons.tag,
              text: 'No tags',
            ),
          ),
        );
      },
    );
  }

  CollectionFilter _buildFilter(String tag) => TagFilter(tag);

  Map<String, ImageEntry> _getTagEntries() {
    final pinned = settings.pinnedFilters.whereType<TagFilter>().map((f) => f.tag);

    final entriesByDate = source.sortedEntriesForFilterList;
    // tags are initially sorted by name at the source level
    var sortedTags = source.sortedTags;
    if (settings.tagSortFactor == ChipSortFactor.count) {
      var filtersWithCount = List.of(sortedTags.map((s) => MapEntry(s, source.count(_buildFilter(s)))));
      filtersWithCount.sort(FilterNavigationPage.compareChipsByEntryCount);
      sortedTags = filtersWithCount.map((kv) => kv.key).toList();
    }

    final allMapEntries = sortedTags.map((tag) => MapEntry(
          tag,
          entriesByDate.firstWhere((entry) => entry.xmpSubjects.contains(tag), orElse: () => null),
        ));
    final byPin = groupBy<MapEntry<String, ImageEntry>, bool>(allMapEntries, (e) => pinned.contains(e.key));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    if (settings.tagSortFactor == ChipSortFactor.date) {
      pinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
      unpinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
    }

    return Map.fromEntries([...pinnedMapEntries, ...unpinnedMapEntries]);
  }
}
