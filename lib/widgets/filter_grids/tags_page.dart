import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
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

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, Tuple2<ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple2(s.tagSortFactor, s.pinnedFilters),
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage<TagFilter>(
            source: source,
            title: context.l10n.tagPageTitle,
            chipSetActionDelegate: TagChipSetActionDelegate(),
            chipActionDelegate: ChipActionDelegate(),
            chipActionsBuilder: (filter) => [
              settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
              ChipAction.setCover,
              ChipAction.hide,
            ],
            filterSections: _getTagEntries(source),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.tag,
              text: context.l10n.tagEmpty,
            ),
          ),
        );
      },
    );
  }

  Map<ChipSectionKey, List<FilterGridItem<TagFilter>>> _getTagEntries(CollectionSource source) {
    final filters = source.sortedTags.map((tag) => TagFilter(tag)).toSet();

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
