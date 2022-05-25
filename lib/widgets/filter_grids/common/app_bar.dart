import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class FilterGridAppBar<T extends CollectionFilter> extends StatefulWidget {
  final CollectionSource source;
  final String title;
  final ChipSetActionDelegate<T> actionDelegate;
  final bool isEmpty;

  const FilterGridAppBar({
    super.key,
    required this.source,
    required this.title,
    required this.actionDelegate,
    required this.isEmpty,
  });

  @override
  State<FilterGridAppBar<T>> createState() => _FilterGridAppBarState<T>();
}

class _FilterGridAppBarState<T extends CollectionFilter> extends State<FilterGridAppBar<T>> with SingleTickerProviderStateMixin {
  late AnimationController _browseToSelectAnimation;
  final ValueNotifier<bool> _isSelectingNotifier = ValueNotifier(false);

  CollectionSource get source => widget.source;

  ChipSetActionDelegate get actionDelegate => widget.actionDelegate;

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
    _browseToSelectAnimation = AnimationController(
      duration: context.read<DurationsData>().iconAnimation,
      vsync: this,
    );
    _isSelectingNotifier.addListener(_onActivityChange);
  }

  @override
  void dispose() {
    _isSelectingNotifier.removeListener(_onActivityChange);
    _browseToSelectAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final selection = context.watch<Selection<FilterGridItem<T>>>();
    final isSelecting = selection.isSelecting;
    _isSelectingNotifier.value = isSelecting;
    return AvesAppBar(
      contentHeight: kToolbarHeight,
      leading: _buildAppBarLeading(
        hasDrawer: appMode.hasDrawer,
        isSelecting: isSelecting,
      ),
      title: _buildAppBarTitle(isSelecting),
      actions: _buildActions(appMode, selection),
      transitionKey: isSelecting,
    );
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
      return Selector<Selection<FilterGridItem<T>>, int>(
        selector: (context, selection) => selection.selectedItems.length,
        builder: (context, count, child) => Text(count == 0 ? l10n.collectionSelectPageTitle : l10n.itemCount(count)),
      );
    } else {
      final appMode = context.watch<ValueNotifier<AppMode>>().value;
      return InteractiveAppBarTitle(
        onTap: appMode.canSearch ? _goToSearch : null,
        child: SourceStateAwareAppBarTitle(
          title: Text(widget.title),
          source: source,
        ),
      );
    }
  }

  List<Widget> _buildActions(AppMode appMode, Selection<FilterGridItem<T>> selection) {
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
          (action) => _toActionButton(action, enabled: canApply(action)),
        );

    return [
      ...quickActionButtons,
      MenuIconTheme(
        child: PopupMenuButton<ChipSetAction>(
          itemBuilder: (context) {
            final generalMenuItems = ChipSetActions.general.where(isVisible).map(
                  (action) => _toMenuItem(action, enabled: canApply(action)),
                );

            final browsingMenuActions = ChipSetActions.browsing.where((v) => !browsingQuickActions.contains(v));
            final selectionMenuActions = ChipSetActions.selection.where((v) => !selectionQuickActions.contains(v));
            final contextualMenuItems = (isSelecting ? selectionMenuActions : browsingMenuActions).where(isVisible).map(
                  (action) => _toMenuItem(action, enabled: canApply(action)),
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
            // wait for the popup menu to hide before proceeding with the action
            await Future.delayed(Durations.popupMenuAnimation * timeDilation);
            _onActionSelected(action);
          },
        ),
      ),
    ];
  }

  Widget _toActionButton(ChipSetAction action, {required bool enabled}) {
    return IconButton(
      icon: action.getIcon(),
      onPressed: enabled ? () => _onActionSelected(action) : null,
      tooltip: action.getText(context),
    );
  }

  PopupMenuItem<ChipSetAction> _toMenuItem(ChipSetAction action, {required bool enabled}) {
    return PopupMenuItem(
      value: action,
      enabled: enabled,
      child: MenuRow(text: action.getText(context), icon: action.getIcon()),
    );
  }

  void _onActivityChange() {
    if (context.read<Selection<FilterGridItem<T>>>().isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
    }
  }

  void _onActionSelected(ChipSetAction action) {
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
