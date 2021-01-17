import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
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
          builder: (context, snapshot) => FilterNavigationPage<TagFilter>(
            source: source,
            title: 'Tags',
            chipSetActionDelegate: TagChipSetActionDelegate(source: source),
            chipActionDelegate: ChipActionDelegate(),
            chipActionsBuilder: (filter) => [
              settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
            ],
            filterSections: _getTagEntries(),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.tag,
              text: 'No tags',
            ),
          ),
        );
      },
    );
  }

  Map<ChipSectionKey, List<FilterGridItem<TagFilter>>> _getTagEntries() {
    // tags are initially sorted by name at the source level
    final filters = source.sortedTags.map((tag) => TagFilter(tag));

    final sorted = FilterNavigationPage.sort(settings.tagSortFactor, source, filters);
    return _group(sorted);
  }

  static Map<ChipSectionKey, List<FilterGridItem<TagFilter>>> _group(Iterable<FilterGridItem<TagFilter>> sortedMapEntries) {
    final pinned = settings.pinnedFilters.whereType<TagFilter>();
    final byPin = groupBy<FilterGridItem<TagFilter>, bool>(sortedMapEntries, (e) => pinned.contains(e.filter));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    return {
      if (pinnedMapEntries.isNotEmpty || unpinnedMapEntries.isNotEmpty)
        ChipSectionKey(): [
          ...pinnedMapEntries,
          ...unpinnedMapEntries,
        ],
    };
  }
}
