import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/tag_set.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class TagListPage extends StatelessWidget {
  static const routeName = '/tags';

  final Uri? initialGroup;

  const new({
    super.key,
    required this.initialGroup,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FilterGrouping>.value(value: tagGrouping),
        FilterGroupProvider(initialValue: initialGroup),
      ],
      child: Builder(
        // to access filter group provider from subtree context
        builder: (context) {
          final source = context.read<CollectionSource>();
          return Selector<Settings, (ChipSectionFactor, ChipSortFactor, bool, Set<CollectionFilter>)>(
            selector: (context, s) => (s.tagSectionFactor, s.tagSortFactor, s.tagSortReverse, s.pinnedFilters),
            shouldRebuild: (t1, t2) {
              // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within records
              const eq = DeepCollectionEquality();
              return !(eq.equals(t1.$1, t2.$1) && eq.equals(t1.$2, t2.$2) && eq.equals(t1.$3, t2.$3) && eq.equals(t1.$4, t2.$4));
            },
            builder: (context, _, child) {
              return ListenableBuilder(
                listenable: tagGrouping,
                builder: (context, child) => StreamBuilder<TagsChangedEvent>(
                  stream: source.eventBus.on<TagsChangedEvent>(),
                  builder: (context, _) {
                    final groupUri = context.watch<FilterGroupNotifier>().value;
                    final gridItems = getGridItems(source, ChipType.values.toSet(), groupUri);
                    return FilterNavigationPage<TagBaseFilter, TagChipSetActionDelegate>(
                      source: source,
                      title: context.l10n.tagPageTitle,
                      sortFactor: settings.tagSortFactor,
                      showHeaders: settings.tagSectionFactor != ChipSectionFactor.none,
                      actionDelegate: TagChipSetActionDelegate(gridItems),
                      filterSections: groupToSections(context, gridItems),
                      emptyBuilder: () => EmptyContent(
                        icon: AIcons.tag,
                        text: context.l10n.tagEmpty,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // common with picking page

  static List<FilterGridItem<TagBaseFilter>> getGridItems(
    CollectionSource source,
    Set<ChipType> chipTypes,
    Uri? groupUri,
  ) {
    final groupContent = tagGrouping.getDirectChildren(groupUri);

    Set<T> whereTypeRecursively<T>(Set<CollectionFilter> filters) {
      return {
        ...filters.whereType<T>(),
        ...filters.whereType<TagGroupFilter>().expand((v) => whereTypeRecursively<T>(v.filter.innerFilters)),
      };
    }

    final listedTags = <String>{};
    if (chipTypes.contains(ChipType.regular)) {
      final allTags = source.sortedTags;
      if (groupUri == null) {
        final withinGroups = whereTypeRecursively<TagFilter>(groupContent).map((v) => v.tag).toSet();
        listedTags.addAll(allTags.whereNot(withinGroups.contains));
      } else {
        // check that group content is listed from source, to prevent displaying hidden content
        listedTags.addAll(groupContent.whereType<TagFilter>().map((v) => v.tag).where(allTags.contains));
      }
    }

    // always show groups, which are needed to navigate to other types
    final tagGroupFilters = groupContent.whereType<TagGroupFilter>().whereNot(settings.hiddenFilters.contains).toSet();

    final filters = <TagBaseFilter>{
      ...tagGroupFilters,
      ...listedTags.map(TagFilter.new),
    };

    return FilterNavigationPage.sort(settings.tagSortFactor, settings.tagSortReverse, source, filters);
  }

  static Map<ChipSectionKey, List<FilterGridItem<TagBaseFilter>>> groupToSections(BuildContext context, Iterable<FilterGridItem<TagBaseFilter>> sortedMapEntries) {
    final pinned = settings.pinnedFilters.whereType<TagFilter>();
    final byPin = groupBy<FilterGridItem<TagBaseFilter>, bool>(sortedMapEntries, (v) => pinned.contains(v.filter));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    var sections = <ChipSectionKey, List<FilterGridItem<TagBaseFilter>>>{};
    switch (settings.tagSectionFactor) {
      case ChipSectionFactor.importance:
        final groupKey = ChipImportanceSectionKey.group(context);
        final regularKey = ChipImportanceSectionKey.regular(context, AIcons.tag);
        sections = groupBy<FilterGridItem<TagBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final filter = kv.filter;
          switch (filter) {
            case TagGroupFilter _:
              return groupKey;
            case TagFilter _:
            default:
              return regularKey;
          }
        });

        sections = {
          // group ordering
          if (sections.containsKey(groupKey)) groupKey: sections[groupKey]!,
          if (sections.containsKey(regularKey)) regularKey: sections[regularKey]!,
        };
      case ChipSectionFactor.mimeType:
      case ChipSectionFactor.volume:
      case ChipSectionFactor.none:
        return {
          if (sortedMapEntries.isNotEmpty)
            const ChipSectionKey(): [
              ...pinnedMapEntries,
              ...unpinnedMapEntries,
            ],
        };
    }

    if (pinnedMapEntries.isNotEmpty) {
      sections = Map.fromEntries([
        MapEntry(ChipImportanceSectionKey.pinned(context), pinnedMapEntries),
        ...sections.entries,
      ]);
    }

    return sections;
  }
}
