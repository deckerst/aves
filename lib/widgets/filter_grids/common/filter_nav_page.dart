import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/common/app_bar.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class FilterNavigationPage<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends StatefulWidget {
  final CollectionSource source;
  final String title;
  final ChipSortFactor sortFactor;
  final bool showHeaders;
  final CSAD actionDelegate;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final Set<T>? newFilters;
  final QueryTest<T> applyQuery;
  final Widget Function() emptyBuilder;

  const FilterNavigationPage({
    super.key,
    required this.source,
    required this.title,
    required this.sortFactor,
    this.showHeaders = false,
    required this.actionDelegate,
    required this.filterSections,
    this.newFilters,
    required this.applyQuery,
    required this.emptyBuilder,
  });

  @override
  State<FilterNavigationPage<T, CSAD>> createState() => _FilterNavigationPageState<T, CSAD>();

  static int compareFiltersByDate(FilterGridItem<CollectionFilter> a, FilterGridItem<CollectionFilter> b) {
    final c = (b.entry?.bestDate ?? epoch).compareTo(a.entry?.bestDate ?? epoch);
    return c != 0 ? c : a.filter.compareTo(b.filter);
  }

  static int compareFiltersByEntryCount(MapEntry<CollectionFilter, num> a, MapEntry<CollectionFilter, num> b) {
    final c = b.value.compareTo(a.value);
    return c != 0 ? c : a.key.compareTo(b.key);
  }

  static int compareFiltersBySize(MapEntry<CollectionFilter, num> a, MapEntry<CollectionFilter, num> b) {
    final c = b.value.compareTo(a.value);
    return c != 0 ? c : a.key.compareTo(b.key);
  }

  static int compareFiltersByName(FilterGridItem<CollectionFilter> a, FilterGridItem<CollectionFilter> b) {
    return a.filter.compareTo(b.filter);
  }

  static List<FilterGridItem<T>> sort<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>>(
    ChipSortFactor sortFactor,
    bool reverse,
    CollectionSource source,
    Set<T> filters,
  ) {
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
      case ChipSortFactor.date:
        allMapEntries = toGridItem(source, filters)..sort(compareFiltersByDate);
      case ChipSortFactor.count:
        final filtersWithCount = List.of(filters.map((filter) => MapEntry(filter, source.count(filter))));
        filtersWithCount.sort(compareFiltersByEntryCount);
        filters = filtersWithCount.map((kv) => kv.key).toSet();
        allMapEntries = toGridItem(source, filters);
      case ChipSortFactor.size:
        final filtersWithSize = List.of(filters.map((filter) => MapEntry(filter, source.size(filter))));
        filtersWithSize.sort(compareFiltersBySize);
        filters = filtersWithSize.map((kv) => kv.key).toSet();
        allMapEntries = toGridItem(source, filters);
    }
    if (reverse) {
      allMapEntries = allMapEntries.reversed.toList();
    }
    return allMapEntries;
  }
}

class _FilterNavigationPageState<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends State<FilterNavigationPage<T, CSAD>> {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return SelectionProvider<FilterGridItem<T>>(
      child: Builder(
        builder: (context) => QueryProvider(
          child: FilterGridPage<T>(
            appBar: FilterGridAppBar<T, CSAD>(
              source: widget.source,
              title: widget.title,
              actionDelegate: widget.actionDelegate,
              isEmpty: widget.filterSections.isEmpty,
              appBarHeightNotifier: _appBarHeightNotifier,
            ),
            appBarHeightNotifier: _appBarHeightNotifier,
            sections: widget.filterSections,
            newFilters: widget.newFilters ?? {},
            sortFactor: widget.sortFactor,
            showHeaders: widget.showHeaders,
            selectable: true,
            applyQuery: widget.applyQuery,
            emptyBuilder: () => ValueListenableBuilder<SourceState>(
              valueListenable: widget.source.stateNotifier,
              builder: (context, sourceState, child) {
                return sourceState != SourceState.loading ? widget.emptyBuilder() : const SizedBox();
              },
            ),
            // do not always enable hero, otherwise unwanted hero gets triggered
            // when using `Show in [...]` action from a chip in the Collection filter bar
            heroType: HeroType.onTap,
          ),
        ),
      ),
    );
  }
}
