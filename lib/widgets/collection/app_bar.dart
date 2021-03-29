import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/collection_actions.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/app_shortcut_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/search/search_button.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
  EntrySetActionDelegate _actionDelegate;
  AnimationController _browseToSelectAnimation;
  Future<bool> _canAddShortcutsLoader;

  CollectionLens get collection => widget.collection;

  CollectionSource get source => collection.source;

  bool get hasFilters => collection.filters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _actionDelegate = EntrySetActionDelegate(
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
  void didUpdateWidget(covariant CollectionAppBar oldWidget) {
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
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        return AnimatedBuilder(
          animation: collection.filterChangeNotifier,
          builder: (context, child) {
            final removableFilters = appMode != AppMode.pickInternal;
            return SliverAppBar(
              leading: appMode.hasDrawer ? _buildAppBarLeading() : null,
              title: _buildAppBarTitle(),
              actions: _buildActions(),
              bottom: hasFilters
                  ? FilterBar(
                      filters: collection.filters,
                      removable: removableFilters,
                      onTap: removableFilters ? collection.removeFilter : null,
                    )
                  : null,
              titleSpacing: 0,
              floating: true,
            );
          },
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
      onPressed = collection.browse;
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
      final appMode = context.watch<ValueNotifier<AppMode>>().value;
      Widget title = Text(appMode.isPicking ? context.l10n.collectionPickPageTitle : context.l10n.collectionPageTitle);
      if (appMode == AppMode.main) {
        title = SourceStateAwareAppBarTitle(
          title: title,
          source: source,
        );
      }
      return InteractiveAppBarTitle(
        onTap: appMode.canSearch ? _goToSearch : null,
        child: title,
      );
    } else if (collection.isSelecting) {
      return AnimatedBuilder(
        animation: collection.selectionChangeNotifier,
        builder: (context, child) {
          final count = collection.selection.length;
          return Text(context.l10n.collectionSelectionPageTitle(count));
        },
      );
    }
    return null;
  }

  List<Widget> _buildActions() {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    return [
      if (collection.isBrowsing && appMode.canSearch)
        CollectionSearchButton(
          source,
          parentCollection: collection,
        ),
      if (collection.isSelecting)
        ...EntryActions.selection.map((action) => AnimatedBuilder(
              animation: collection.selectionChangeNotifier,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(action.getIcon()),
                  onPressed: collection.selection.isEmpty ? null : () => _actionDelegate.onEntryActionSelected(context, action),
                  tooltip: action.getText(context),
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
              final isNotEmpty = !collection.isEmpty;
              final hasSelection = collection.selection.isNotEmpty;
              return [
                PopupMenuItem(
                  key: Key('menu-sort'),
                  value: CollectionAction.sort,
                  child: MenuRow(text: context.l10n.menuActionSort, icon: AIcons.sort),
                ),
                if (collection.sortFactor == EntrySortFactor.date)
                  PopupMenuItem(
                    key: Key('menu-group'),
                    value: CollectionAction.group,
                    child: MenuRow(text: context.l10n.menuActionGroup, icon: AIcons.group),
                  ),
                if (collection.isBrowsing && appMode == AppMode.main) ...[
                  PopupMenuItem(
                    value: CollectionAction.select,
                    enabled: isNotEmpty,
                    child: MenuRow(text: context.l10n.collectionActionSelect, icon: AIcons.select),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.stats,
                    enabled: isNotEmpty,
                    child: MenuRow(text: context.l10n.menuActionStats, icon: AIcons.stats),
                  ),
                  if (canAddShortcuts)
                    PopupMenuItem(
                      value: CollectionAction.addShortcut,
                      child: MenuRow(text: context.l10n.collectionActionAddShortcut, icon: AIcons.addShortcut),
                    ),
                ],
                if (collection.isSelecting) ...[
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: CollectionAction.copy,
                    enabled: hasSelection,
                    child: MenuRow(text: context.l10n.collectionActionCopy),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.move,
                    enabled: hasSelection,
                    child: MenuRow(text: context.l10n.collectionActionMove),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.refreshMetadata,
                    enabled: hasSelection,
                    child: MenuRow(text: context.l10n.collectionActionRefreshMetadata),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: CollectionAction.selectAll,
                    enabled: collection.selection.length < collection.entryCount,
                    child: MenuRow(text: context.l10n.collectionActionSelectAll),
                  ),
                  PopupMenuItem(
                    value: CollectionAction.selectNone,
                    enabled: hasSelection,
                    child: MenuRow(text: context.l10n.collectionActionSelectNone),
                  ),
                ]
              ];
            },
            onSelected: (action) {
              // wait for the popup menu to hide before proceeding with the action
              Future.delayed(Durations.popupMenuAnimation * timeDilation, () => _onCollectionActionSelected(action));
            },
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

  Future<void> _onCollectionActionSelected(CollectionAction action) async {
    switch (action) {
      case CollectionAction.copy:
      case CollectionAction.move:
      case CollectionAction.refreshMetadata:
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
        _goToStats();
        break;
      case CollectionAction.addShortcut:
        unawaited(_showShortcutDialog(context));
        break;
      case CollectionAction.group:
        final value = await showDialog<EntryGroupFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<EntryGroupFactor>(
            initialValue: settings.collectionGroupFactor,
            options: {
              EntryGroupFactor.album: context.l10n.collectionGroupAlbum,
              EntryGroupFactor.month: context.l10n.collectionGroupMonth,
              EntryGroupFactor.day: context.l10n.collectionGroupDay,
              EntryGroupFactor.none: context.l10n.collectionGroupNone,
            },
            title: context.l10n.collectionGroupTitle,
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
              EntrySortFactor.date: context.l10n.collectionSortDate,
              EntrySortFactor.size: context.l10n.collectionSortSize,
              EntrySortFactor.name: context.l10n.collectionSortName,
            },
            title: context.l10n.collectionSortTitle,
          ),
        );
        if (value != null) {
          settings.collectionSortFactor = value;
          collection.sort(value);
        }
        break;
    }
  }

  Future<void> _showShortcutDialog(BuildContext context) async {
    final filters = collection.filters;
    var defaultName;
    if (filters.isNotEmpty) {
      // we compute the default name beforehand
      // because some filter labels need localization
      final sortedFilters = List<CollectionFilter>.from(filters)..sort();
      defaultName = sortedFilters.first.getLabel(context);
    }
    final result = await showDialog<Tuple2<AvesEntry, String>>(
      context: context,
      builder: (context) => AddShortcutDialog(
        collection: collection,
        defaultName: defaultName,
      ),
    );
    final coverEntry = result.item1;
    final name = result.item2;

    if (name == null || name.isEmpty) return;

    unawaited(AppShortcutService.pin(name, coverEntry, filters));
  }

  void _goToSearch() {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: CollectionSearchDelegate(
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
          source: source,
          parentCollection: collection,
        ),
      ),
    );
  }
}
