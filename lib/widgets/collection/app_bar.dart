import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/collection/query_bar.dart';
import 'package:aves/widgets/common/action_controls/togglers/favourite.dart';
import 'package:aves/widgets/common/action_controls/togglers/title_search.dart';
import 'package:aves/widgets/common/app_bar/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/basic/popup/container.dart';
import 'package:aves/widgets/common/basic/popup/expansion_panel.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

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
    _isSelectingNotifier.addListener(_onActivityChanged);
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
    _queryBarFocusNode.dispose();
    _queryFocusRequestNotifier.removeListener(_onQueryFocusRequest);
    _isSelectingNotifier.dispose();
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
    // when top padding changes
    _updateStatusBarHeight();
    // when text scale factor changes
    _updateAppBarHeight();
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final selection = context.watch<Selection<AvesEntry>>();
    final isSelecting = selection.isSelecting;
    _isSelectingNotifier.value = isSelecting;
    return NotificationListener<ScrollNotification>(
      // cancel notification bubbling so that the draggable scroll bar
      // does not misinterpret filter bar scrolling for collection scrolling
      onNotification: (notification) => true,
      child: AnimatedBuilder(
        animation: collection.filterChangeNotifier,
        builder: (context, child) {
          final removableFilters = appMode != AppMode.pickMediaInternal;
          return Selector<Query, bool>(
            selector: (context, query) => query.enabled,
            builder: (context, queryEnabled, child) {
              return Selector<Settings, List<EntrySetAction>>(
                selector: (context, s) => s.collectionBrowsingQuickActions,
                builder: (context, _, child) {
                  final useTvLayout = settings.useTvLayout;
                  final actions = _buildActions(context, selection);
                  final onFilterTap = removableFilters ? collection.removeFilter : null;
                  return AvesAppBar(
                    contentHeight: appBarContentHeight,
                    pinned: context.select<Selection<AvesEntry>, bool>((selection) => selection.isSelecting),
                    leading: _buildAppBarLeading(
                      hasDrawer: appMode.canNavigate,
                      isSelecting: isSelecting,
                    ),
                    title: _buildAppBarTitle(isSelecting),
                    actions: useTvLayout ? [] : actions,
                    bottom: Column(
                      children: [
                        if (useTvLayout)
                          SizedBox(
                            height: CaptionedButton.getTelevisionButtonHeight(context),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              scrollDirection: Axis.horizontal,
                              children: actions,
                            ),
                          ),
                        if (showFilterBar)
                          NotificationListener<FilterNotification>(
                            onNotification: (notification) {
                              collection.addFilter(notification.filter);
                              return true;
                            },
                            child: FilterBar(
                              filters: visibleFilters,
                              onTap: onFilterTap,
                              onRemove: onFilterTap,
                            ),
                          ),
                        if (queryEnabled)
                          EntryQueryBar(
                            queryNotifier: context.select<Query, ValueNotifier<String>>((query) => query.queryNotifier),
                            focusNode: _queryBarFocusNode,
                          ),
                      ],
                    ),
                    transitionKey: isSelecting,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  double get appBarContentHeight {
    final textScaler = MediaQuery.textScalerOf(context);
    double height = textScaler.scale(kToolbarHeight);
    if (settings.useTvLayout) {
      height += CaptionedButton.getTelevisionButtonHeight(context);
    }
    if (showFilterBar) {
      height += FilterBar.preferredHeight;
    }
    if (context.read<Query>().enabled) {
      height += EntryQueryBar.getPreferredHeight(textScaler);
    }
    return height;
  }

  Widget? _buildAppBarLeading({required bool hasDrawer, required bool isSelecting}) {
    if (settings.useTvLayout) return null;

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
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final isSelecting = selection.isSelecting;
    final selectedItemCount = selection.selectedItems.length;

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

    return settings.useTvLayout
        ? _buildTelevisionActions(
            context: context,
            appMode: appMode,
            selection: selection,
            isVisible: isVisible,
            canApply: canApply,
          )
        : _buildMobileActions(
            context: context,
            appMode: appMode,
            selection: selection,
            isVisible: isVisible,
            canApply: canApply,
          );
  }

  List<Widget> _buildTelevisionActions({
    required BuildContext context,
    required AppMode appMode,
    required Selection<AvesEntry> selection,
    required bool Function(EntrySetAction action) isVisible,
    required bool Function(EntrySetAction action) canApply,
  }) {
    final isSelecting = selection.isSelecting;

    return [
      ...EntrySetActions.general,
      ...isSelecting ? EntrySetActions.pageSelection : EntrySetActions.pageBrowsing,
    ].whereNotNull().where(isVisible).map((action) {
      final enabled = canApply(action);
      return CaptionedButton(
        iconButtonBuilder: (context, focusNode) => _buildButtonIcon(
          context,
          action,
          enabled: enabled,
          selection: selection,
          focusNode: focusNode,
        ),
        captionText: _buildButtonCaption(context, action, enabled: enabled),
        onPressed: enabled ? () => _onActionSelected(action) : null,
      );
    }).toList();
  }

  List<Widget> _buildMobileActions({
    required BuildContext context,
    required AppMode appMode,
    required Selection<AvesEntry> selection,
    required bool Function(EntrySetAction action) isVisible,
    required bool Function(EntrySetAction action) canApply,
  }) {
    final isSelecting = selection.isSelecting;
    final selectedItemCount = selection.selectedItems.length;
    final hasSelection = selectedItemCount > 0;

    final browsingQuickActions = settings.collectionBrowsingQuickActions;
    final selectionQuickActions = isTrash ? [EntrySetAction.delete, EntrySetAction.restore] : settings.collectionSelectionQuickActions;
    final quickActionButtons = (isSelecting ? selectionQuickActions : browsingQuickActions).where(isVisible).map(
          (action) => _buildButtonIcon(context, action, enabled: canApply(action), selection: selection),
        );

    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);
    return [
      ...quickActionButtons,
      PopupMenuButton<EntrySetAction>(
        // key is expected by test driver
        key: const Key('appbar-menu-button'),
        itemBuilder: (context) {
          final generalMenuItems = EntrySetActions.general.where(isVisible).map(
                (action) => _toMenuItem(action, enabled: canApply(action), selection: selection),
              );

          final browsingMenuActions = EntrySetActions.pageBrowsing.where((v) => !browsingQuickActions.contains(v));
          final selectionMenuActions = EntrySetActions.pageSelection.where((v) => !selectionQuickActions.contains(v));
          final contextualMenuActions = (isSelecting ? selectionMenuActions : browsingMenuActions).where((v) => v == null || isVisible(v)).fold(<EntrySetAction?>[], (prev, v) {
            if (v == null && (prev.isEmpty || prev.last == null)) return prev;
            return [...prev, v];
          });
          if (contextualMenuActions.isNotEmpty && contextualMenuActions.last == null) {
            contextualMenuActions.removeLast();
          }

          final contextualMenuItems = <PopupMenuEntry<EntrySetAction>>[
            ...contextualMenuActions.map(
              (action) {
                if (action == null) return const PopupMenuDivider();
                return _toMenuItem(action, enabled: canApply(action), selection: selection);
              },
            ),
            if (isSelecting && !settings.isReadOnly && appMode == AppMode.main && !isTrash)
              PopupMenuExpansionPanel<EntrySetAction>(
                enabled: hasSelection,
                value: 'edit',
                icon: AIcons.edit,
                title: context.l10n.collectionActionEdit,
                items: [
                  _buildRotateAndFlipMenuItems(context, canApply: canApply),
                  ...EntrySetActions.edit.where((v) => isVisible(v) && !selectionQuickActions.contains(v)).map((action) => _toMenuItem(action, enabled: canApply(action), selection: selection)),
                ],
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
          await Future.delayed(animations.popUpAnimationDelay * timeDilation);
          await _onActionSelected(action);
        },
        popUpAnimationStyle: animations.popUpAnimationStyle,
      ),
    ];
  }

  Set<AvesEntry> _getExpandedSelectedItems(Selection<AvesEntry> selection) {
    return selection.selectedItems.expand((entry) => entry.burstEntries ?? {entry}).toSet();
  }

  // key is expected by test driver (e.g. 'menu-configureView', 'menu-map')
  Key _getActionKey(EntrySetAction action) => Key('menu-${action.name}');

  Widget _buildButtonIcon(
    BuildContext context,
    EntrySetAction action, {
    required bool enabled,
    FocusNode? focusNode,
    required Selection<AvesEntry> selection,
  }) {
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
              focusNode: focusNode,
            );
          },
        );
      case EntrySetAction.toggleFavourite:
        return FavouriteToggler(
          entries: _getExpandedSelectedItems(selection),
          focusNode: focusNode,
          onPressed: onPressed,
        );
      default:
        return IconButton(
          key: _getActionKey(action),
          icon: action.getIcon(),
          onPressed: onPressed,
          focusNode: focusNode,
          tooltip: action.getText(context),
        );
    }
  }

  Widget _buildButtonCaption(
    BuildContext context,
    EntrySetAction action, {
    required bool enabled,
  }) {
    switch (action) {
      case EntrySetAction.toggleTitleSearch:
        return TitleSearchTogglerCaption(
          enabled: enabled,
        );
      default:
        return CaptionedButtonText(
          text: action.getText(context),
          enabled: enabled,
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
      case EntrySetAction.toggleFavourite:
        child = FavouriteToggler(
          entries: _getExpandedSelectedItems(selection),
          isMenuItem: true,
        );
      default:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
    }
    return PopupMenuItem(
      key: _getActionKey(action),
      value: action,
      enabled: enabled,
      child: child,
    );
  }

  PopupMenuEntry<EntrySetAction> _buildRotateAndFlipMenuItems(
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
            color: Colors.transparent,
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

    return PopupMenuItemContainer(
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
    );
  }

  void _onActivityChanged() {
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
    _statusBarHeight = MediaQuery.paddingOf(context).top;
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
      case EntrySetAction.select:
        context.read<Selection<AvesEntry>>().select();
      case EntrySetAction.selectAll:
        context.read<Selection<AvesEntry>>().addToSelection(collection.sortedEntries);
      case EntrySetAction.selectNone:
        context.read<Selection<AvesEntry>>().clearSelection();
      // browsing
      case EntrySetAction.searchCollection:
      case EntrySetAction.toggleTitleSearch:
      case EntrySetAction.addShortcut:
      case EntrySetAction.setHome:
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
      case EntrySetAction.convert:
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
    }
  }

  Future<void> _configureView() async {
    final initialValue = (
      settings.collectionSortFactor,
      settings.collectionSectionFactor,
      settings.getTileLayout(CollectionPage.routeName),
      settings.collectionSortReverse,
    );
    final extentController = context.read<TileExtentController>();
    final value = await showDialog<(EntrySortFactor?, EntryGroupFactor?, TileLayout?, bool)>(
      context: context,
      builder: (context) {
        return TileViewDialog<EntrySortFactor, EntryGroupFactor, TileLayout>(
          initialValue: initialValue,
          sortOptions: _sortOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          groupOptions: _groupOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          layoutOptions: _layoutOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          sortOrder: (factor, reverse) => factor.getOrderName(context, reverse),
          canGroup: (s, g, l) => s == EntrySortFactor.date,
          tileExtentController: extentController,
        );
      },
      routeSettings: const RouteSettings(name: TileViewDialog.routeName),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(ADurations.dialogTransitionAnimation * timeDilation);
    if (value != null && initialValue != value) {
      settings.collectionSortFactor = value.$1!;
      settings.collectionSectionFactor = value.$2!;
      settings.setTileLayout(CollectionPage.routeName, value.$3!);
      settings.collectionSortReverse = value.$4;
    }
  }

  void _goToSearch() {
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          searchFieldStyle: Themes.searchFieldStyle(context),
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }
}
