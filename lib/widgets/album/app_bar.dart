import 'dart:async';

import 'package:aves/main.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/filter_bar.dart';
import 'package:aves/widgets/album/search/search_delegate.dart';
import 'package:aves/widgets/common/action_delegates/selection_action_delegate.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';

class CollectionAppBar extends StatefulWidget {
  final ValueNotifier<double> appBarHeightNotifier;
  final CollectionLens collection;

  const CollectionAppBar({
    Key key,
    @required this.appBarHeightNotifier,
    @required this.collection,
  }) : super(key: key);

  @override
  _CollectionAppBarState createState() => _CollectionAppBarState();
}

class _CollectionAppBarState extends State<CollectionAppBar> with SingleTickerProviderStateMixin {
  final TextEditingController _searchFieldController = TextEditingController();
  SelectionActionDelegate _actionDelegate;
  AnimationController _browseToSelectAnimation;

  CollectionLens get collection => widget.collection;

  bool get hasFilters => collection.filters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _actionDelegate = SelectionActionDelegate(
      collection: collection,
    );
    _browseToSelectAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void didUpdateWidget(CollectionAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _browseToSelectAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(CollectionAppBar widget) {
    widget.collection.activityNotifier.addListener(_onActivityChange);
    widget.collection.filterChangeNotifier.addListener(_updateHeight);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    widget.collection.activityNotifier.removeListener(_onActivityChange);
    widget.collection.filterChangeNotifier.removeListener(_updateHeight);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        return AnimatedBuilder(
          animation: collection.filterChangeNotifier,
          builder: (context, child) => SliverAppBar(
            titleSpacing: 0,
            leading: _buildAppBarLeading(),
            title: _buildAppBarTitle(),
            actions: _buildActions(),
            bottom: hasFilters ? FilterBar() : null,
            floating: true,
          ),
        );
      },
    );
  }

  Widget _buildAppBarLeading() {
    VoidCallback onPressed;
    String tooltip;
    if (collection.isBrowsing) {
      onPressed = Scaffold.of(context).openDrawer;
      tooltip = MaterialLocalizations.of(context).openAppDrawerTooltip;
    } else if (collection.isSelecting) {
      onPressed = () {
        collection.clearSelection();
        collection.browse();
      };
      tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    }
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _browseToSelectAnimation,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildAppBarTitle() {
    if (collection.isBrowsing) {
      final title = AvesApp.mode == AppMode.pick ? 'Select' : 'Aves';
      return GestureDetector(
        onTap: _goToSearch,
        // use a `Container` with a dummy color to make it expand
        // so that we can also detect taps around the title `Text`
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: NavigationToolbar.kMiddleSpacing),
          color: Colors.transparent,
          height: kToolbarHeight,
          child: Text(title),
        ),
      );
    } else if (collection.isSelecting) {
      return AnimatedBuilder(
        animation: collection.selectionChangeNotifier,
        builder: (context, child) {
          final count = collection.selection.length;
          return Text(Intl.plural(count, zero: 'Select items', one: '${count} item', other: '${count} items'));
        },
      );
    }
    return null;
  }

  List<Widget> _buildActions() {
    return [
      if (collection.isBrowsing)
        IconButton(
          icon: const Icon(AIcons.search),
          onPressed: _goToSearch,
        ),
      if (collection.isSelecting)
        ...EntryActions.selection.map((action) => AnimatedBuilder(
              animation: collection.selectionChangeNotifier,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(action.getIcon()),
                  onPressed: collection.selection.isEmpty ? null : () => _actionDelegate.onEntryActionSelected(context, action),
                  tooltip: action.getText(),
                );
              },
            )),
      Builder(
        builder: (context) => PopupMenuButton<CollectionAction>(
          itemBuilder: (context) => [
            ..._buildSortMenuItems(),
            ..._buildGroupMenuItems(),
            if (collection.isBrowsing) ...[
              if (AvesApp.mode == AppMode.main)
                const PopupMenuItem(
                  value: CollectionAction.select,
                  child: MenuRow(text: 'Select', icon: AIcons.select),
                ),
              const PopupMenuItem(
                value: CollectionAction.stats,
                child: MenuRow(text: 'Stats', icon: AIcons.stats),
              ),
            ],
            if (collection.isSelecting) ...[
              const PopupMenuItem(
                value: CollectionAction.copy,
                child: MenuRow(text: 'Copy to album'),
              ),
              const PopupMenuItem(
                value: CollectionAction.move,
                // TODO TLAD enable when handled on native side
                enabled: false,
                child: MenuRow(text: 'Move to album'),
              ),
              const PopupMenuItem(
                value: CollectionAction.selectAll,
                child: MenuRow(text: 'Select all'),
              ),
              const PopupMenuItem(
                value: CollectionAction.selectNone,
                child: MenuRow(text: 'Select none'),
              ),
            ]
          ],
          onSelected: _onCollectionActionSelected,
        ),
      ),
    ];
  }

  List<PopupMenuEntry<CollectionAction>> _buildSortMenuItems() {
    return [
      PopupMenuItem(
        value: CollectionAction.sortByDate,
        child: MenuRow(text: 'Sort by date', checked: collection.sortFactor == SortFactor.date),
      ),
      PopupMenuItem(
        value: CollectionAction.sortBySize,
        child: MenuRow(text: 'Sort by size', checked: collection.sortFactor == SortFactor.size),
      ),
      PopupMenuItem(
        value: CollectionAction.sortByName,
        child: MenuRow(text: 'Sort by name', checked: collection.sortFactor == SortFactor.name),
      ),
      const PopupMenuDivider(),
    ];
  }

  List<PopupMenuEntry<CollectionAction>> _buildGroupMenuItems() {
    return collection.sortFactor == SortFactor.date
        ? [
            PopupMenuItem(
              value: CollectionAction.groupByAlbum,
              child: MenuRow(text: 'Group by album', checked: collection.groupFactor == GroupFactor.album),
            ),
            PopupMenuItem(
              value: CollectionAction.groupByMonth,
              child: MenuRow(text: 'Group by month', checked: collection.groupFactor == GroupFactor.month),
            ),
            PopupMenuItem(
              value: CollectionAction.groupByDay,
              child: MenuRow(text: 'Group by day', checked: collection.groupFactor == GroupFactor.day),
            ),
            const PopupMenuDivider(),
          ]
        : [];
  }

  void _onActivityChange() {
    if (collection.isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
      _searchFieldController.clear();
    }
  }

  void _updateHeight() {
    widget.appBarHeightNotifier.value = kToolbarHeight + (hasFilters ? FilterBar.preferredHeight : 0);
  }

  void _onCollectionActionSelected(CollectionAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Constants.popupMenuTransitionDuration);
    switch (action) {
      case CollectionAction.copy:
      case CollectionAction.move:
        _actionDelegate.onCollectionActionSelected(context, action);
        break;
      case CollectionAction.select:
        collection.select();
        break;
      case CollectionAction.selectAll:
        collection.addToSelection(collection.sortedEntries);
        break;
      case CollectionAction.selectNone:
        collection.clearSelection();
        break;
      case CollectionAction.stats:
        unawaited(_goToStats());
        break;
      case CollectionAction.groupByAlbum:
        settings.collectionGroupFactor = GroupFactor.album;
        collection.group(GroupFactor.album);
        break;
      case CollectionAction.groupByMonth:
        settings.collectionGroupFactor = GroupFactor.month;
        collection.group(GroupFactor.month);
        break;
      case CollectionAction.groupByDay:
        settings.collectionGroupFactor = GroupFactor.day;
        collection.group(GroupFactor.day);
        break;
      case CollectionAction.sortByDate:
        settings.collectionSortFactor = SortFactor.date;
        collection.sort(SortFactor.date);
        break;
      case CollectionAction.sortBySize:
        settings.collectionSortFactor = SortFactor.size;
        collection.sort(SortFactor.size);
        break;
      case CollectionAction.sortByName:
        settings.collectionSortFactor = SortFactor.name;
        collection.sort(SortFactor.name);
        break;
    }
  }

  Future<void> _goToSearch() async {
    final filter = await showSearch(
      context: context,
      delegate: ImageSearchDelegate(collection.source),
    );
    collection.addFilter(filter);
  }

  Future<void> _goToStats() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsPage(
          collection: collection,
        ),
      ),
    );
  }
}

enum CollectionAction { copy, move, select, selectAll, selectNone, stats, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize, sortByName }
