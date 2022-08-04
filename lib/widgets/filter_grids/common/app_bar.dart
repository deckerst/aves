import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/app_bar/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/app_bar/title_search_toggler.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/common/query_bar.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

typedef ActionsBuilder<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> = List<Widget> Function(
  BuildContext context,
  AppMode appMode,
  Selection<FilterGridItem<T>> selection,
  CSAD actionDelegate,
);

class FilterGridAppBar<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends StatefulWidget {
  final CollectionSource source;
  final String title;
  final CSAD actionDelegate;
  final ActionsBuilder<T, CSAD>? actionsBuilder;
  final bool isEmpty;
  final ValueNotifier<double> appBarHeightNotifier;

  const FilterGridAppBar({
    super.key,
    required this.source,
    required this.title,
    required this.actionDelegate,
    this.actionsBuilder,
    required this.isEmpty,
    required this.appBarHeightNotifier,
  });

  @override
  State<FilterGridAppBar<T, CSAD>> createState() => _FilterGridAppBarState<T, CSAD>();

  static PopupMenuItem<ChipSetAction> toMenuItem(BuildContext context, ChipSetAction action, {required bool enabled}) {
    late Widget child;
    switch (action) {
      case ChipSetAction.toggleTitleSearch:
        child = TitleSearchToggler(
          queryEnabled: context.read<Query>().enabled,
          isMenuItem: true,
        );
        break;
      default:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }

    return PopupMenuItem(
      value: action,
      enabled: enabled,
      child: child,
    );
  }
}

class _FilterGridAppBarState<T extends CollectionFilter, CSAD extends ChipSetActionDelegate<T>> extends State<FilterGridAppBar<T, CSAD>> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  late AnimationController _browseToSelectAnimation;
  final ValueNotifier<bool> _isSelectingNotifier = ValueNotifier(false);
  final FocusNode _queryBarFocusNode = FocusNode();
  late final Listenable _queryFocusRequestNotifier;

  CollectionSource get source => widget.source;

  static const browsingQuickActions = [
    ChipSetAction.search,
  ];
  static const selectionQuickActions = [
    ChipSetAction.setCover,
    ChipSetAction.pin,
    ChipSetAction.unpin,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAppBarHeight());
  }

  @override
  void dispose() {
    _queryFocusRequestNotifier.removeListener(_onQueryFocusRequest);
    _isSelectingNotifier.removeListener(_onActivityChange);
    _browseToSelectAnimation.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final selection = context.watch<Selection<FilterGridItem<T>>>();
    final isSelecting = selection.isSelecting;
    _isSelectingNotifier.value = isSelecting;
    return Selector<Query, bool>(
      selector: (context, query) => query.enabled,
      builder: (context, queryEnabled, child) {
        ActionsBuilder<T, CSAD> actionsBuilder = widget.actionsBuilder ?? _buildActions;
        return AvesAppBar(
          contentHeight: appBarContentHeight,
          leading: _buildAppBarLeading(
            hasDrawer: appMode.canNavigate,
            isSelecting: isSelecting,
          ),
          title: _buildAppBarTitle(isSelecting),
          actions: actionsBuilder(context, appMode, selection, widget.actionDelegate),
          bottom: queryEnabled
              ? FilterQueryBar<T>(
                  queryNotifier: context.select<Query, ValueNotifier<String>>((query) => query.queryNotifier),
                  focusNode: _queryBarFocusNode,
                )
              : null,
          transitionKey: isSelecting,
        );
      },
    );
  }

  double get appBarContentHeight {
    final hasQuery = context.read<Query>().enabled;
    return kToolbarHeight + (hasQuery ? FilterQueryBar.preferredHeight : .0);
  }

  Widget _buildAppBarLeading({required bool hasDrawer, required bool isSelecting}) {
    if (!hasDrawer) {
      return const CloseButton();
    }

    VoidCallback? onPressed;
    String? tooltip;
    if (isSelecting) {
      onPressed = () => context.read<Selection<FilterGridItem<T>>>().browse();
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
    if (isSelecting) {
      final l10n = context.l10n;
      return Selector<Selection<FilterGridItem<T>>?, int>(
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
      return InteractiveAppBarTitle(
        onTap: appMode.canNavigate ? _goToSearch : null,
        child: SourceStateAwareAppBarTitle(
          title: Text(widget.title),
          source: source,
        ),
      );
    }
  }

  List<Widget> _buildActions(
    BuildContext context,
    AppMode appMode,
    Selection<FilterGridItem<T>> selection,
    CSAD actionDelegate,
  ) {
    final itemCount = actionDelegate.allItems.length;
    final isSelecting = selection.isSelecting;
    final selectedItems = selection.selectedItems;
    final selectedFilters = selectedItems.map((v) => v.filter).toSet();

    bool isVisible(ChipSetAction action) => actionDelegate.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    bool canApply(ChipSetAction action) => actionDelegate.canApply(
          action,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );

    final quickActionButtons = (isSelecting ? selectionQuickActions : browsingQuickActions).where(isVisible).map(
          (action) => _toActionButton(context, actionDelegate, action, enabled: canApply(action)),
        );

    return [
      ...quickActionButtons,
      MenuIconTheme(
        child: PopupMenuButton<ChipSetAction>(
          itemBuilder: (context) {
            final generalMenuItems = ChipSetActions.general.where(isVisible).map(
                  (action) => FilterGridAppBar.toMenuItem(context, action, enabled: canApply(action)),
                );

            final browsingMenuActions = ChipSetActions.browsing.where((v) => !browsingQuickActions.contains(v));
            final selectionMenuActions = ChipSetActions.selection.where((v) => !selectionQuickActions.contains(v));
            final contextualMenuItems = (isSelecting ? selectionMenuActions : browsingMenuActions).where(isVisible).map(
                  (action) => FilterGridAppBar.toMenuItem(context, action, enabled: canApply(action)),
                );

            return [
              ...generalMenuItems,
              if (contextualMenuItems.isNotEmpty) ...[
                const PopupMenuDivider(),
                ...contextualMenuItems,
              ],
            ];
          },
          onSelected: (action) async {
            // remove focus, if any, to prevent the keyboard from showing up
            // after the user is done with the popup menu
            FocusManager.instance.primaryFocus?.unfocus();

            // wait for the popup menu to hide before proceeding with the action
            await Future.delayed(Durations.popupMenuAnimation * timeDilation);
            _onActionSelected(context, action, actionDelegate);
          },
        ),
      ),
    ];
  }

  Widget _toActionButton(
    BuildContext context,
    CSAD actionDelegate,
    ChipSetAction action, {
    required bool enabled,
  }) {
    final onPressed = enabled ? () => _onActionSelected(context, action, actionDelegate) : null;
    switch (action) {
      case ChipSetAction.toggleTitleSearch:
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
      default:
        return IconButton(
          icon: action.getIcon(),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
    }
  }

  void _onActivityChange() {
    if (context.read<Selection<FilterGridItem<T>>>().isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
    }
  }

  void _onQueryFocusRequest() => _queryBarFocusNode.requestFocus();

  void _updateAppBarHeight() {
    widget.appBarHeightNotifier.value = AvesAppBar.appBarHeightForContentHeight(appBarContentHeight);
  }

  void _onActionSelected(BuildContext context, ChipSetAction action, ChipSetActionDelegate<T> actionDelegate) {
    final selection = context.read<Selection<FilterGridItem<T>>>();
    final selectedFilters = selection.selectedItems.map((v) => v.filter).toSet();
    actionDelegate.onActionSelected(context, selectedFilters, action);
  }

  void _goToSearch() {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          source: source,
        ),
      ),
    );
  }
}
