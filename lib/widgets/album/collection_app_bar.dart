import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/album/filter_bar.dart';
import 'package:aves/widgets/album/search/search_delegate.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class CollectionAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<PageState> stateNotifier;

  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight + FilterBar.preferredHeight);

  CollectionAppBar({this.stateNotifier});

  @override
  _CollectionAppBarState createState() => _CollectionAppBarState();
}

class _CollectionAppBarState extends State<CollectionAppBar> with SingleTickerProviderStateMixin {
  final TextEditingController _searchFieldController = TextEditingController();

  AnimationController _browseToSearchAnimation;

  ValueNotifier<PageState> get stateNotifier => widget.stateNotifier;

  @override
  void initState() {
    super.initState();
    _browseToSearchAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _registerWidget(widget);
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
    _browseToSearchAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(CollectionAppBar widget) {
    stateNotifier.addListener(_onStateChange);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    stateNotifier.removeListener(_onStateChange);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PageState>(
      valueListenable: stateNotifier,
      builder: (context, state, child) {
        debugPrint('$runtimeType builder state=$state');
        return SliverAppBar(
          leading: _buildAppBarLeading(),
          title: _buildAppBarTitle(),
          actions: _buildActions(),
          bottom: FilterBar(),
          floating: true,
        );
      },
    );
  }

  Widget _buildAppBarLeading() {
    VoidCallback onPressed;
    String tooltip;
    switch (stateNotifier.value) {
      case PageState.browse:
        onPressed = () => Scaffold.of(context).openDrawer();
        tooltip = MaterialLocalizations.of(context).openAppDrawerTooltip;
        break;
      case PageState.search:
        onPressed = () => stateNotifier.value = PageState.browse;
        tooltip = MaterialLocalizations.of(context).backButtonTooltip;
        break;
    }
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _browseToSearchAnimation,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildAppBarTitle() {
    switch (stateNotifier.value) {
      case PageState.browse:
        return const Text('Aves');
      case PageState.search:
        return SearchField(
          stateNotifier: stateNotifier,
          controller: _searchFieldController,
        );
    }
    return null;
  }

  List<Widget> _buildActions() {
    return [
      Builder(
        builder: (context) {
          switch (stateNotifier.value) {
            case PageState.browse:
              return Consumer<CollectionLens>(
                builder: (context, collection, child) => IconButton(
                  icon: Icon(OMIcons.search),
                  onPressed: () async {
                    final filter = await showSearch(
                      context: context,
                      delegate: ImageSearchDelegate(collection),
                    );
                    collection.addFilter(filter);
                  },
                ),
              );
            case PageState.search:
              return IconButton(
                icon: Icon(OMIcons.clear),
                onPressed: () => _searchFieldController.clear(),
              );
          }
          return null;
        },
      ),
      Builder(
        builder: (context) => Consumer<CollectionLens>(
          builder: (context, collection, child) => PopupMenuButton<CollectionAction>(
            itemBuilder: (context) => [
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
              if (collection.sortFactor == SortFactor.date) ...[
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
              ],
              PopupMenuItem(
                value: CollectionAction.stats,
                child: MenuRow(text: 'Stats', icon: OMIcons.pieChart),
              ),
            ],
            onSelected: (action) => _onActionSelected(collection, action),
          ),
        ),
      ),
    ];
  }

  void _onActionSelected(CollectionLens collection, CollectionAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(const Duration(milliseconds: 300));
    switch (action) {
      case CollectionAction.stats:
        unawaited(_goToStats(collection));
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

  Future<void> _goToStats(CollectionLens collection) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsPage(
          collection: collection,
        ),
      ),
    );
  }

  void _onStateChange() {
    if (stateNotifier.value == PageState.search) {
      _browseToSearchAnimation.forward();
    } else {
      _browseToSearchAnimation.reverse();
      _searchFieldController.clear();
    }
  }
}

class SearchField extends StatelessWidget {
  final ValueNotifier<PageState> stateNotifier;
  final TextEditingController controller;

  const SearchField({
    @required this.stateNotifier,
    @required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<CollectionLens>(context);
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
      autofocus: true,
      onSubmitted: (query) {
        query = query.trim();
        if (query.isNotEmpty) {
          collection.addFilter(QueryFilter(query));
        }
        stateNotifier.value = PageState.browse;
      },
    );
  }
}

enum CollectionAction { stats, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize, sortByName }
