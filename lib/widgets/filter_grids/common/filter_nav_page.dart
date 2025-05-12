import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/common/app_bar.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends StatefulWidget {
  final CollectionSource source;
  final String title;
  final ChipSortFactor sortFactor;
  final bool showHeaders;
  final CSAD actionDelegate;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final Set<T>? newFilters;
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

  static int compareFiltersByPath<T extends CollectionFilter>(FilterGridItem<T> a, FilterGridItem<T> b) {
    if (T == AlbumBaseFilter) {
      final filterA = a.filter;
      final filterB = b.filter;
      final pathA = filterA is StoredAlbumFilter ? filterA.album : '';
      final pathB = filterB is StoredAlbumFilter ? filterB.album : '';
      final c = pathA.compareTo(pathB);
      return c != 0 ? c : a.filter.compareTo(b.filter);
    }
    return 0;
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
      case ChipSortFactor.path:
        allMapEntries = toGridItem(source, filters)..sort(compareFiltersByPath);
    }
    if (reverse) {
      allMapEntries = allMapEntries.reversed.toList();
    }
    return allMapEntries;
  }
}

class _FilterNavigationPageState<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends State<FilterNavigationPage<T, CSAD>> with FeedbackMixin, VaultAwareMixin {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _appBarHeightNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionProvider<FilterGridItem<T>>(
      child: Builder(
        builder: (context) => QueryProvider(
          startEnabled: settings.getShowTitleQuery(context.currentRouteName!),
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
            emptyBuilder: () => ValueListenableBuilder<SourceState>(
              valueListenable: widget.source.stateNotifier,
              builder: (context, sourceState, child) {
                return sourceState != SourceState.loading ? widget.emptyBuilder() : const SizedBox();
              },
            ),
            // do not always enable hero, otherwise unwanted hero gets triggered
            // when using `Show in [...]` action from a chip in the Collection filter bar
            heroType: HeroType.onTap,
            onTileTap: (gridItem, navigate) async {
              final selection = context.read<Selection<FilterGridItem<T>>?>();
              if (selection != null && selection.isSelecting) {
                selection.toggleSelection(gridItem);
              } else {
                final filter = gridItem.filter;
                if (!await unlockFilter(context, filter)) return;

                if (filter is AlbumGroupFilter) {
                  context.read<FilterGroupNotifier>().value = filter.uri;
                } else {
                  final route = MaterialPageRoute(
                    settings: const RouteSettings(name: CollectionPage.routeName),
                    builder: (context) => CollectionPage(
                      source: context.read<CollectionSource>(),
                      filters: {gridItem.filter},
                    ),
                  );
                  navigate(route);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
