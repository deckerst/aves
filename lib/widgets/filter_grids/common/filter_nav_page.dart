import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/common/app_bar.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilterNavigationPage<T extends CollectionFilter> extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final ChipSortFactor sortFactor;
  final bool groupable, showHeaders;
  final ChipSetActionDelegate actionDelegate;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final Set<T>? newFilters;
  final Widget Function() emptyBuilder;

  const FilterNavigationPage({
    Key? key,
    required this.source,
    required this.title,
    required this.sortFactor,
    this.groupable = false,
    this.showHeaders = false,
    required this.actionDelegate,
    required this.filterSections,
    this.newFilters,
    required this.emptyBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionProvider<FilterGridItem<T>>(
      child: Builder(
        builder: (context) => FilterGridPage<T>(
          appBar: FilterGridAppBar<T>(
            source: source,
            title: title,
            actionDelegate: actionDelegate,
            groupable: groupable,
            isEmpty: filterSections.isEmpty,
          ),
          sections: filterSections,
          newFilters: newFilters ?? {},
          sortFactor: sortFactor,
          showHeaders: showHeaders,
          selectable: true,
          queryNotifier: ValueNotifier(''),
          emptyBuilder: () => ValueListenableBuilder<SourceState>(
            valueListenable: source.stateNotifier,
            builder: (context, sourceState, child) {
              return sourceState != SourceState.loading ? emptyBuilder() : const SizedBox.shrink();
            },
          ),
          onTap: (filter) => _goToCollection(context, filter),
        ),
      ),
    );
  }

  void _goToCollection(BuildContext context, CollectionFilter filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          collection: CollectionLens(
            source: source,
            filters: [filter],
          ),
        ),
      ),
    );
  }

  static int compareFiltersByDate(FilterGridItem<CollectionFilter> a, FilterGridItem<CollectionFilter> b) {
    final c = (b.entry?.bestDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.entry?.bestDate ?? DateTime.fromMillisecondsSinceEpoch(0));
    return c != 0 ? c : a.filter.compareTo(b.filter);
  }

  static int compareFiltersByEntryCount(MapEntry<CollectionFilter, num> a, MapEntry<CollectionFilter, num> b) {
    final c = b.value.compareTo(a.value);
    return c != 0 ? c : a.key.compareTo(b.key);
  }

  static int compareFiltersByName(FilterGridItem<CollectionFilter> a, FilterGridItem<CollectionFilter> b) {
    return a.filter.compareTo(b.filter);
  }

  static List<FilterGridItem<T>> sort<T extends CollectionFilter>(ChipSortFactor sortFactor, CollectionSource source, Set<T> filters) {
    List<FilterGridItem<T>> toGridItem(CollectionSource source, Set<T> filters) {
      return filters
          .map((filter) => FilterGridItem(
                filter,
                source.recentEntry(filter),
              ))
          .toList();
    }

    List<FilterGridItem<T>> allMapEntries = [];
    switch (sortFactor) {
      case ChipSortFactor.name:
        allMapEntries = toGridItem(source, filters)..sort(compareFiltersByName);
        break;
      case ChipSortFactor.date:
        allMapEntries = toGridItem(source, filters)..sort(compareFiltersByDate);
        break;
      case ChipSortFactor.count:
        final filtersWithCount = List.of(filters.map((filter) => MapEntry(filter, source.count(filter))));
        filtersWithCount.sort(compareFiltersByEntryCount);
        filters = filtersWithCount.map((kv) => kv.key).toSet();
        allMapEntries = toGridItem(source, filters);
        break;
    }
    return allMapEntries;
  }
}
