import 'dart:async';
import 'dart:ui';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums/enums.dart';
import 'package:aves/model/source/enums/view.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/collection/query_bar.dart';
import 'package:aves/widgets/common/app_bar/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/app_bar/favourite_toggler.dart';
import 'package:aves/widgets/common/app_bar/title_search_toggler.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CollectionAppBar extends StatefulWidget {
  final ValueNotifier<double> appBarHeightNotifier;
  final CollectionLens collection;

  const CollectionAppBar({
    super.key,
    required this.appBarHeightNotifier,
    required this.collection,
  });

  @override
  State<CollectionAppBar> createState() => _CollectionAppBarState();
}

class _CollectionAppBarState extends State<CollectionAppBar> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<StreamSubscription> _subscriptions = [];
  final EntrySetActionDelegate _actionDelegate = EntrySetActionDelegate();
  late AnimationController _browseToSelectAnimation;
  final ValueNotifier<bool> _isSelectingNotifier = ValueNotifier(false);
  final FocusNode _queryBarFocusNode = FocusNode();
  late final Listenable _queryFocusRequestNotifier;
  double _statusBarHeight = 0;

  CollectionLens get collection => widget.collection;

  bool get isTrash => collection.filters.contains(TrashFilter.instance);

  CollectionSource get source => collection.source;

  Set<CollectionFilter> get visibleFilters => collection.filters.where((v) => !(v is QueryFilter && v.live) && v is! TrashFilter).toSet();

  bool get showFilterBar => visibleFilters.isNotEmpty;

  static const _sortOptions = [
    EntrySortFactor.date,
    EntrySortFactor.size,
    EntrySortFactor.name,
    EntrySortFactor.rating,
  ];

  static const _groupOptions = [
    EntryGroupFactor.album,
    EntryGroupFactor.month,
    EntryGroupFactor.day,
    EntryGroupFactor.none,
  ];

  static const _layoutOptions = [
    TileLayout.mosaic,
    TileLayout.grid,
    TileLayout.list,
  ];

  @override
  void initState() {
    super.initState();
    final query = context.read<Query>();
    _subscriptions.add(query.enabledStream.listen((e) => _updateAppBarHeight()));
    _queryFocusRequestNotifier = query.focusRequestNotifier;
    _queryFocusRequestNotifier.addListener(_onQueryFocusRequest);
    _browseToSelectAnimation = AnimationController(
      duration: context.read<DurationsData>().iconAnimation,
      vsync: this,
    );
    _isSelectingNotifier.addListener(_onActivityChange);
    _registerWidget(widget);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusBarHeight();
      _onFilterChanged();
    });
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
    _queryFocusRequestNotifier.removeListener(_onQueryFocusRequest);
    _isSelectingNotifier.removeListener(_onActivityChange);
    _browseToSelectAnimation.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _registerWidget(CollectionAppBar widget) {
    widget.collection.filterChangeNotifier.addListener(_onFilterChanged);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    widget.collection.filterChangeNotifier.removeListener(_onFilterChanged);
  }

  @override
  void didChangeMetrics() {
    _updateStatusBarHeight();
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final selection = context.watch<Selection<AvesEntry>>();
    final isSelecting = selection.isSelecting;
    _isSelectingNotifier.value = isSelecting;
    return AnimatedBuilder(
      animation: collection.filterChangeNotifier,
      builder: (context, child) {
        final removableFilters = appMode != AppMode.pickMediaInternal;
        return Selector<Query, bool>(
          selector: (context, query) => query.enabled,
          builder: (context, queryEnabled, child) {
            return Selector<Settings, List<EntrySetAction>>(
              selector: (context, s) => s.collectionBrowsingQuickActions,
              builder: (context, _, child) {
                return AvesAppBar(
                  contentHeight: appBarContentHeight,
                  leading: _buildAppBarLeading(
                    hasDrawer: appMode.canNavigate,
                    isSelecting: isSelecting,
                  ),
                  title: _buildAppBarTitle(isSelecting),
                  actions: _buildActions(context, selection),
                  bottom: Column(
                    children: [
                      if (showFilterBar)
                        NotificationListener<ReverseFilterNotification>(
                          onNotification: (notification) {
                            collection.addFilter(notification.reversedFilter);
                            return true;
                          },
                          child: FilterBar(
                            filters: visibleFilters,
                            removable: removableFilters,
                            onTap: removableFilters ? collection.removeFilter : null,
                          ),
                        ),
                      if (queryEnabled)
                        EntryQueryBar(
                          queryNotifier: context.select<Query, ValueNotifier<String>>((query) => query.queryNotifier),
                          focusNode: _queryBarFocusNode,
                        )
                    ],
                  ),
                  transitionKey: isSelecting,
                );
              },
            );
          },
        );
      },
    );
  }

  double get appBarContentHeight {
    final hasQuery = context.read<Query>().enabled;
    return kToolbarHeight + (showFilterBar ? FilterBar.preferredHeight : .0) + (hasQuery ? EntryQueryBar.preferredHeight : .0);
  }

  Widget _buildAppBarLeading({required bool hasDrawer, required bool isSelecting}) {
    if (!hasDrawer) {
      return const CloseButton();
    }

    VoidCallback? onPressed;
    String? tooltip;
    if (isSelecting) {
      onPressed = () => context.read<Selection<AvesEntry>>().browse();
      tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    } else {
      onPressed = Scaffold.of(context).openDrawer;
      tooltip = MaterialLocalizations.of(context).openAppDrawerTooltip;
    }
    return IconButton(
      // key is expected by test driver
      key: const Key('appbar-leading-button'),
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _browseToSelectAnimation,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildAppBarTitle(bool isSelecting) {
    final l10n = context.l10n;

    if (isSelecting) {
      // `Selection` may not be available during hero
      return Selector<Selection<AvesEntry>?, int>(
        selector: (context, selection) => selection?.selectedItems.length ?? 0,
        builder: (context, count, child) => Text(
          count == 0 ? l10n.collectionSelectPageTitle : l10n.itemCount(count),
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );
    } else {
      final appMode = context.watch<ValueNotifier<AppMode>>().value;
      Widget title = Text(
        appMode.isPickingMedia ? l10n.collectionPickPageTitle : (isTrash ? l10n.binPageTitle : l10n.collectionPageTitle),
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      );
      if (appMode == AppMode.main) {
        title = SourceStateAwareAppBarTitle(
          title: title,
          source: source,
        );
      }
      return InteractiveAppBarTitle(
        onTap: appMode.canNavigate ? _goToSearch : null,
        child: title,
      );
    }
  }

  List<Widget> _buildActions(BuildContext context, Selection<AvesEntry> selection) {
    final isSelecting = selection.isSelecting;
    final selectedItemCount = selection.selectedItems.length;

    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    bool isVisible(EntrySetAction action) => _actionDelegate.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: collection.entryCount,
          selectedItemCount: selectedItemCount,
          isTrash: isTrash,
        );
    bool canApply(EntrySetAction action) => _actionDelegate.canApply(
          action,
          isSelecting: isSelecting,
          itemCount: collection.entryCount,
          selectedItemCount: selectedItemCount,
        );
    final canApplyEditActions = selectedItemCount > 0;

    final browsingQuickActions = settings.collectionBrowsingQuickActions;
    final selectionQuickActions = isTrash ? [EntrySetAction.delete, EntrySetAction.restore] : settings.collectionSelectionQuickActions;
    final quickActionButtons = (isSelecting ? selectionQuickActions : browsingQuickActions).where(isVisible).map(
          (action) => _toActionButton(action, enabled: canApply(action), selection: selection),
        );

    return [
      ...quickActionButtons,
      MenuIconTheme(
        child: PopupMenuButton<EntrySetAction>(
          // key is expected by test driver
          key: const Key('appbar-menu-button'),
          itemBuilder: (context) {
            final generalMenuItems = EntrySetActions.general.where(isVisible).map(
                  (action) => _toMenuItem(action, enabled: canApply(action), selection: selection),
                );

            final browsingMenuActions = EntrySetActions.pageBrowsing.where((v) => !browsingQuickActions.contains(v));
            final selectionMenuActions = EntrySetActions.pageSelection.where((v) => !selectionQuickActions.contains(v));
            final contextualMenuItems = [
              ...(isSelecting ? selectionMenuActions : browsingMenuActions).where(isVisible).map(
                    (action) => _toMenuItem(action, enabled: canApply(action), selection: selection),
                  ),
              if (isSelecting && !device.isReadOnly && appMode == AppMode.main && !isTrash)
                PopupMenuItem<EntrySetAction>(
                  enabled: canApplyEditActions,
                  padding: EdgeInsets.zero,
                  child: PopupMenuItemExpansionPanel<EntrySetAction>(
                    enabled: canApplyEditActions,
                    value: 'edit',
                    icon: AIcons.edit,
                    title: context.l10n.collectionActionEdit,
                    items: [
                      _buildRotateAndFlipMenuItems(context, canApply: canApply),
                      ...EntrySetActions.edit.where((v) => isVisible(v) && !selectionQuickActions.contains(v)).map((action) => _toMenuItem(action, enabled: canApply(action), selection: selection)),
                    ],
                  ),
                ),
            ];

            return [
              ...generalMenuItems,
              if (contextualMenuItems.isNotEmpty) ...[
                const PopupMenuDivider(),
                ...contextualMenuItems,
              ],
            ];
          },
          onSelected: (action) async {
            // wait for the popup menu to hide before proceeding with the action
            await Future.delayed(Durations.popupMenuAnimation * timeDilation);
            await _onActionSelected(action);
          },
        ),
      ),
    ];
  }

  Set<AvesEntry> _getExpandedSelectedItems(Selection<AvesEntry> selection) {
    return selection.selectedItems.expand((entry) => entry.burstEntries ?? {entry}).toSet();
  }

  // key is expected by test driver (e.g. 'menu-configureView', 'menu-map')
  Key _getActionKey(EntrySetAction action) => Key('menu-${action.name}');

  Widget _toActionButton(EntrySetAction action, {required bool enabled, required Selection<AvesEntry> selection}) {
    final onPressed = enabled ? () => _onActionSelected(action) : null;
    switch (action) {
      case EntrySetAction.toggleTitleSearch:
        // `Query` may not be available during hero
        return Selector<Query?, bool>(
          selector: (context, query) => query?.enabled ?? false,
          builder: (context, queryEnabled, child) {
            return TitleSearchToggler(
              queryEnabled: queryEnabled,
              onPressed: onPressed,
            );
          },
        );
      case EntrySetAction.toggleFavourite:
        return FavouriteToggler(
          entries: _getExpandedSelectedItems(selection),
          onPressed: onPressed,
        );
      default:
        return IconButton(
          key: _getActionKey(action),
          icon: action.getIcon(),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
    }
  }

  PopupMenuItem<EntrySetAction> _toMenuItem(EntrySetAction action, {required bool enabled, required Selection<AvesEntry> selection}) {
    late Widget child;
    switch (action) {
      case EntrySetAction.toggleTitleSearch:
        child = TitleSearchToggler(
          queryEnabled: context.read<Query>().enabled,
          isMenuItem: true,
        );
        break;
      case EntrySetAction.toggleFavourite:
        child = FavouriteToggler(
          entries: _getExpandedSelectedItems(selection),
          isMenuItem: true,
        );
        break;
      default:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }
    return PopupMenuItem(
      key: _getActionKey(action),
      value: action,
      enabled: enabled,
      child: child,
    );
  }

  PopupMenuItem<EntrySetAction> _buildRotateAndFlipMenuItems(
    BuildContext context, {
    required bool Function(EntrySetAction action) canApply,
  }) {
    Widget buildDivider() => const SizedBox(
          height: 16,
          child: VerticalDivider(
            width: 1,
            thickness: 1,
          ),
        );

    Widget buildItem(EntrySetAction action) => Expanded(
          child: Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: PopupMenuItem(
              value: action,
              enabled: canApply(action),
              child: Tooltip(
                message: action.getText(context),
                child: Center(child: action.getIcon()),
              ),
            ),
          ),
        );

    return PopupMenuItem(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Row(
          children: [
            buildDivider(),
            buildItem(EntrySetAction.rotateCCW),
            buildDivider(),
            buildItem(EntrySetAction.rotateCW),
            buildDivider(),
            buildItem(EntrySetAction.flip),
            buildDivider(),
          ],
        ),
      ),
    );
  }

  void _onActivityChange() {
    if (context.read<Selection<AvesEntry>>().isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
    }
  }

  void _onFilterChanged() {
    _updateAppBarHeight();

    final filters = collection.filters;
    if (filters.isNotEmpty) {
      final selection = context.read<Selection<AvesEntry>>();
      if (selection.isSelecting) {
        final toRemove = selection.selectedItems.where((entry) => !filters.every((f) => f.test(entry))).toSet();
        selection.removeFromSelection(toRemove);
      }
    }
  }

  void _onQueryFocusRequest() => _queryBarFocusNode.requestFocus();

  void _updateStatusBarHeight() {
    _statusBarHeight = EdgeInsets.fromWindowPadding(window.padding, window.devicePixelRatio).top;
    _updateAppBarHeight();
  }

  void _updateAppBarHeight() {
    widget.appBarHeightNotifier.value = _statusBarHeight + AvesAppBar.appBarHeightForContentHeight(appBarContentHeight);
  }

  Future<void> _onActionSelected(EntrySetAction action) async {
    switch (action) {
      // general
      case EntrySetAction.configureView:
        await _configureView();
        break;
      case EntrySetAction.select:
        context.read<Selection<AvesEntry>>().select();
        break;
      case EntrySetAction.selectAll:
        context.read<Selection<AvesEntry>>().addToSelection(collection.sortedEntries);
        break;
      case EntrySetAction.selectNone:
        context.read<Selection<AvesEntry>>().clearSelection();
        break;
      // browsing
      case EntrySetAction.searchCollection:
      case EntrySetAction.toggleTitleSearch:
      case EntrySetAction.addShortcut:
      // browsing or selecting
      case EntrySetAction.map:
      case EntrySetAction.slideshow:
      case EntrySetAction.stats:
      case EntrySetAction.rescan:
      case EntrySetAction.emptyBin:
      // selecting
      case EntrySetAction.share:
      case EntrySetAction.delete:
      case EntrySetAction.restore:
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rename:
      case EntrySetAction.toggleFavourite:
      case EntrySetAction.rotateCCW:
      case EntrySetAction.rotateCW:
      case EntrySetAction.flip:
      case EntrySetAction.editDate:
      case EntrySetAction.editLocation:
      case EntrySetAction.editTitleDescription:
      case EntrySetAction.editRating:
      case EntrySetAction.editTags:
      case EntrySetAction.removeMetadata:
        _actionDelegate.onActionSelected(context, action);
        break;
    }
  }

  Future<void> _configureView() async {
    final initialValue = Tuple4(
      settings.collectionSortFactor,
      settings.collectionSectionFactor,
      settings.getTileLayout(CollectionPage.routeName),
      settings.collectionSortReverse,
    );
    final value = await showDialog<Tuple4<EntrySortFactor?, EntryGroupFactor?, TileLayout?, bool>>(
      context: context,
      builder: (context) {
        return TileViewDialog<EntrySortFactor, EntryGroupFactor, TileLayout>(
          initialValue: initialValue,
          sortOptions: _sortOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          groupOptions: _groupOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          layoutOptions: _layoutOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          sortOrder: (factor, reverse) => factor.getOrderName(context, reverse),
          canGroup: (s, g, l) => s == EntrySortFactor.date,
        );
      },
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (value != null && initialValue != value) {
      settings.collectionSortFactor = value.item1!;
      settings.collectionSectionFactor = value.item2!;
      settings.setTileLayout(CollectionPage.routeName, value.item3!);
      settings.collectionSortReverse = value.item4;
    }
  }

  void _goToSearch() {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }
}
