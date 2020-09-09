import 'dart:async';

import 'package:aves/main.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/app_shortcut_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/collection/collection_actions.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/collection/search/search_delegate.dart';
import 'package:aves/widgets/common/action_delegates/selection_action_delegate.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/data_providers/media_store_collection_provider.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  Future<bool> _canAddShortcutsLoader;

  CollectionLens get collection => widget.collection;

  bool get hasFilters => collection.filters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _actionDelegate = SelectionActionDelegate(
      collection: collection,
    );
    _browseToSelectAnimation = AnimationController(
      duration: Durations.iconAnimation,
      vsync: this,
    );
    _canAddShortcutsLoader = AppShortcutService.canPin();
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
    _searchFieldController.dispose();
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
            bottom: hasFilters
                ? FilterBar(
                    filters: collection.filters,
                    onPressed: collection.removeFilter,
                  )
                : null,
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
      key: Key('appbar-leading-button'),
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
      Widget title = Text(
        AvesApp.mode == AppMode.pick ? 'Pick' : 'Collection',
        key: Key('appbar-title'),
      );
      if (AvesApp.mode == AppMode.main) {
        title = SourceStateAwareAppBarTitle(
          title: title,
          source: collection.source,
        );
      }
      return GestureDetector(
        onTap: _goToSearch,
        // use a `Container` with a dummy color to make it expand
        // so that we can also detect taps around the title `Text`
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.symmetric(horizontal: NavigationToolbar.kMiddleSpacing),
          color: Colors.transparent,
          height: kToolbarHeight,
          child: title,
        ),
      );
    } else if (collection.isSelecting) {
      return AnimatedBuilder(
        animation: collection.selectionChangeNotifier,
        builder: (context, child) {
          final count = collection.selection.length;
          return Text(Intl.plural(count, zero: 'Select items', one: '$count item', other: '$count items'));
        },
      );
    }
    return null;
  }

  List<Widget> _buildActions() {
    return [
      if (collection.isBrowsing)
        IconButton(
          key: Key('search-button'),
          icon: Icon(AIcons.search),
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
      FutureBuilder<bool>(
        future: _canAddShortcutsLoader,
        builder: (context, snapshot) {
          final canAddShortcuts = snapshot.data ?? false;
          return PopupMenuButton<CollectionAction>(
            key: Key('appbar-menu-button'),
            itemBuilder: (context) {
              final hasSelection = collection.selection.isNotEmpty;
              return [
                PopupMenuItem(
                  key: Key('menu-sort'),
                  value: CollectionAction.sort,
                  child: MenuRow(text: 'Sort...', icon: AIcons.sort),
                ),
                if (collection.sortFactor == EntrySortFactor.date)
                  PopupMenuItem(
                    key: Key('menu-group'),
                    value: CollectionAction.group,
                    child: MenuRow(text: 'Group...', icon: AIcons.group),
                  ),
                if (collection.isBrowsing) ...[
                  if (AvesApp.mode == AppMode.main)
                    if (kDebugMode)
                      PopupMenuItem(
                        value: CollectionAction.refresh,
                        child: MenuRow(text: 'Refresh', icon: AIcons.refresh),
                      ),
                  PopupMenuItem(
                    value: CollectionAction.select,
                    child: MenuRow(text: 'Select', icon: AIcons.select),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.stats,
                    child: MenuRow(text: 'Stats', icon: AIcons.stats),
                  ),
                  if (canAddShortcuts)
                    PopupMenuItem(
                      value: CollectionAction.addShortcut,
                      child: MenuRow(text: 'Add shortcut', icon: AIcons.addShortcut),
                    ),
                ],
                if (collection.isSelecting) ...[
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: CollectionAction.copy,
                    enabled: hasSelection,
                    child: MenuRow(text: 'Copy to album'),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.move,
                    enabled: hasSelection,
                    child: MenuRow(text: 'Move to album'),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.refreshMetadata,
                    enabled: hasSelection,
                    child: MenuRow(text: 'Refresh metadata'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: CollectionAction.selectAll,
                    child: MenuRow(text: 'Select all'),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.selectNone,
                    enabled: hasSelection,
                    child: MenuRow(text: 'Select none'),
                  ),
                ]
              ];
            },
            onSelected: _onCollectionActionSelected,
          );
        },
      ),
    ];
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
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);
    switch (action) {
      case CollectionAction.copy:
      case CollectionAction.move:
      case CollectionAction.refreshMetadata:
        _actionDelegate.onCollectionActionSelected(context, action);
        break;
      case CollectionAction.refresh:
        final source = collection.source;
        if (source is MediaStoreSource) {
          source.clearEntries();
          unawaited(source.refresh());
        }
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
        _goToStats();
        break;
      case CollectionAction.addShortcut:
        unawaited(AppShortcutService.pin('Collection', collection.filters));
        break;
      case CollectionAction.group:
        final value = await showDialog<EntryGroupFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<EntryGroupFactor>(
            initialValue: settings.collectionGroupFactor,
            options: {
              EntryGroupFactor.album: 'By album',
              EntryGroupFactor.month: 'By month',
              EntryGroupFactor.day: 'By day',
              EntryGroupFactor.none: 'Do not group',
            },
            title: 'Group',
          ),
        );
        if (value != null) {
          settings.collectionGroupFactor = value;
          collection.group(value);
        }
        break;
      case CollectionAction.sort:
        final value = await showDialog<EntrySortFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<EntrySortFactor>(
            initialValue: settings.collectionSortFactor,
            options: {
              EntrySortFactor.date: 'By date',
              EntrySortFactor.size: 'By size',
              EntrySortFactor.name: 'By album & file name',
            },
            title: 'Sort',
          ),
        );
        if (value != null) {
          settings.collectionSortFactor = value;
          collection.sort(value);
        }
        break;
    }
  }

  void _goToSearch() {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: ImageSearchDelegate(
            source: collection.source,
            parentCollection: collection,
          ),
        ));
  }

  void _goToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: StatsPage.routeName),
        builder: (context) => StatsPage(
          collection: collection,
        ),
      ),
    );
  }
}
