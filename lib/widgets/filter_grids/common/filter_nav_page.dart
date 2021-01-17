import 'dart:ui';

import 'package:aves/main.dart';
import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/search/search_button.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FilterNavigationPage<T extends CollectionFilter> extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final ChipSetActionDelegate chipSetActionDelegate;
  final bool groupable, showHeaders;
  final ChipActionDelegate chipActionDelegate;
  final List<ChipAction> Function(T filter) chipActionsBuilder;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final Widget Function() emptyBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    this.groupable = false,
    this.showHeaders = false,
    @required this.chipSetActionDelegate,
    @required this.chipActionDelegate,
    @required this.chipActionsBuilder,
    @required this.filterSections,
    @required this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FilterGridPage<T>(
      key: ValueKey('filter-grid-page'),
      source: source,
      appBar: SliverAppBar(
        title: TappableAppBarTitle(
          onTap: () => _goToSearch(context),
          child: SourceStateAwareAppBarTitle(
            title: Text(title),
            source: source,
          ),
        ),
        actions: _buildActions(context),
        titleSpacing: 0,
        floating: true,
      ),
      filterSections: filterSections,
      showHeaders: showHeaders,
      queryNotifier: ValueNotifier(''),
      emptyBuilder: () => ValueListenableBuilder<SourceState>(
        valueListenable: source.stateNotifier,
        builder: (context, sourceState, child) {
          return sourceState != SourceState.loading && emptyBuilder != null ? emptyBuilder() : SizedBox.shrink();
        },
      ),
      onTap: (filter) => Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: CollectionPage.routeName),
          builder: (context) => CollectionPage(CollectionLens(
            source: source,
            filters: [filter],
            groupFactor: settings.collectionGroupFactor,
            sortFactor: settings.collectionSortFactor,
          )),
        ),
      ),
      onLongPress: AvesApp.mode == AppMode.main ? (filter, tapPosition) => _showMenu(context, filter, tapPosition) : null,
    );
  }

  Future<void> _showMenu(BuildContext context, T filter, Offset tapPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final touchArea = Size(40, 40);
    // TODO TLAD show menu within safe area
    final selectedAction = await showMenu<ChipAction>(
      context: context,
      position: RelativeRect.fromRect(tapPosition & touchArea, Offset.zero & overlay.size),
      items: chipActionsBuilder(filter)
          .map((action) => PopupMenuItem(
                value: action,
                child: MenuRow(text: action.getText(), icon: action.getIcon()),
              ))
          .toList(),
    );
    if (selectedAction != null) {
      // wait for the popup menu to hide before proceeding with the action
      Future.delayed(Durations.popupMenuAnimation * timeDilation, () => chipActionDelegate.onActionSelected(context, filter, selectedAction));
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      CollectionSearchButton(source),
      PopupMenuButton<ChipSetAction>(
        key: Key('appbar-menu-button'),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              key: Key('menu-sort'),
              value: ChipSetAction.sort,
              child: MenuRow(text: 'Sort…', icon: AIcons.sort),
            ),
            if (groupable)
              PopupMenuItem(
                value: ChipSetAction.group,
                child: MenuRow(text: 'Group…', icon: AIcons.group),
              ),
            if (kDebugMode)
              PopupMenuItem(
                value: ChipSetAction.refresh,
                child: MenuRow(text: 'Refresh', icon: AIcons.refresh),
              ),
            PopupMenuItem(
              value: ChipSetAction.stats,
              child: MenuRow(text: 'Stats', icon: AIcons.stats),
            ),
          ];
        },
        onSelected: (action) {
          // wait for the popup menu to hide before proceeding with the action
          Future.delayed(Durations.popupMenuAnimation * timeDilation, () => chipSetActionDelegate.onActionSelected(context, action));
        },
      ),
    ];
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: CollectionSearchDelegate(
            source: source,
          ),
        ));
  }

  static int compareFiltersByDate(FilterGridItem<CollectionFilter> a, FilterGridItem<CollectionFilter> b) {
    final c = b.entry.bestDate?.compareTo(a.entry.bestDate) ?? -1;
    return c != 0 ? c : a.filter.compareTo(b.filter);
  }

  static int compareFiltersByEntryCount(MapEntry<CollectionFilter, num> a, MapEntry<CollectionFilter, num> b) {
    final c = b.value.compareTo(a.value) ?? -1;
    return c != 0 ? c : a.key.compareTo(b.key);
  }

  static Iterable<FilterGridItem<T>> sort<T extends CollectionFilter>(ChipSortFactor sortFactor, CollectionSource source, Iterable<T> filters) {
    Iterable<FilterGridItem<T>> toGridItem(CollectionSource source, Iterable<T> filters) {
      final entriesByDate = source.sortedEntriesForFilterList;
      return filters.map((filter) => FilterGridItem(
            filter,
            entriesByDate.firstWhere(filter.filter, orElse: () => null),
          ));
    }

    Iterable<FilterGridItem<T>> allMapEntries;
    switch (sortFactor) {
      case ChipSortFactor.name:
        allMapEntries = toGridItem(source, filters);
        break;
      case ChipSortFactor.date:
        allMapEntries = toGridItem(source, filters).toList()..sort(compareFiltersByDate);
        break;
      case ChipSortFactor.count:
        final filtersWithCount = List.of(filters.map((filter) => MapEntry(filter, source.count(filter))));
        filtersWithCount.sort(compareFiltersByEntryCount);
        filters = filtersWithCount.map((kv) => kv.key).toList();
        allMapEntries = toGridItem(source, filters);
        break;
    }
    return allMapEntries;
  }
}
