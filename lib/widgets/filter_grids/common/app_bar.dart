import 'dart:ui';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/search/search_button.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class FilterGridAppBar<T extends CollectionFilter> extends StatefulWidget {
  final CollectionSource source;
  final String title;
  final ChipSetActionDelegate actionDelegate;
  final bool groupable, isEmpty;

  const FilterGridAppBar({
    Key? key,
    required this.source,
    required this.title,
    required this.actionDelegate,
    required this.groupable,
    required this.isEmpty,
  }) : super(key: key);

  @override
  _FilterGridAppBarState createState() => _FilterGridAppBarState<T>();
}

class _FilterGridAppBarState<T extends CollectionFilter> extends State<FilterGridAppBar<T>> with SingleTickerProviderStateMixin {
  late AnimationController _browseToSelectAnimation;
  final ValueNotifier<bool> _isSelectingNotifier = ValueNotifier(false);

  CollectionSource get source => widget.source;

  ChipSetActionDelegate get actionDelegate => widget.actionDelegate;

  static const filterSelectionActions = [
    ChipSetAction.setCover,
    ChipSetAction.pin,
    ChipSetAction.unpin,
    ChipSetAction.delete,
    ChipSetAction.rename,
    ChipSetAction.hide,
  ];
  static const buttonActionCount = 2;

  @override
  void initState() {
    super.initState();
    _browseToSelectAnimation = AnimationController(
      duration: Durations.iconAnimation,
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
    return SliverAppBar(
      leading: appMode.hasDrawer ? _buildAppBarLeading(isSelecting) : null,
      title: _buildAppBarTitle(isSelecting),
      actions: _buildActions(appMode, selection),
      titleSpacing: 0,
      floating: true,
    );
  }

  Widget _buildAppBarLeading(bool isSelecting) {
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
      key: const Key('appbar-leading-button'),
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _browseToSelectAnimation,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget? _buildAppBarTitle(bool isSelecting) {
    if (isSelecting) {
      return Selector<Selection<FilterGridItem<T>>, int>(
        selector: (context, selection) => selection.selection.length,
        builder: (context, count, child) => Text(context.l10n.collectionSelectionPageTitle(count)),
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
    final selectedFilters = selection.selection.map((v) => v.filter).toSet();

    PopupMenuItem<ChipSetAction> toMenuItem(ChipSetAction action, {bool enabled = true}) {
      return PopupMenuItem(
        value: action,
        enabled: enabled && actionDelegate.canApply(selectedFilters, action),
        child: MenuRow(
          text: action.getText(context),
          icon: action.getIcon(),
        ),
      );
    }

    void applyAction(ChipSetAction action) {
      actionDelegate.onActionSelected(context, selectedFilters, action);
      if (filterSelectionActions.contains(action)) {
        selection.browse();
      }
    }

    final isSelecting = selection.isSelecting;
    final selectionRowActions = <ChipSetAction>[];

    final buttonActions = <Widget>[];
    if (isSelecting) {
      final selectedFilters = selection.selection.map((v) => v.filter).toSet();
      final validActions = filterSelectionActions.where((action) => actionDelegate.isValid(selectedFilters, action)).toList();
      buttonActions.addAll(validActions.take(buttonActionCount).map(
        (action) {
          final enabled = actionDelegate.canApply(selectedFilters, action);
          return IconButton(
            icon: Icon(action.getIcon()),
            onPressed: enabled ? () => applyAction(action) : null,
            tooltip: action.getText(context),
          );
        },
      ));
      selectionRowActions.addAll(validActions.skip(buttonActionCount));
    } else if (appMode.canSearch) {
      buttonActions.add(CollectionSearchButton(source: source));
    }

    return [
      ...buttonActions,
      PopupMenuButton<ChipSetAction>(
        key: const Key('appbar-menu-button'),
        itemBuilder: (context) {
          final menuItems = <PopupMenuEntry<ChipSetAction>>[
            toMenuItem(ChipSetAction.sort),
            if (widget.groupable) toMenuItem(ChipSetAction.group),
          ];

          if (isSelecting) {
            final selectedItems = selection.selection;

            if (selectionRowActions.isNotEmpty) {
              menuItems.add(const PopupMenuDivider());
              menuItems.addAll(selectionRowActions.map(toMenuItem));
            }

            menuItems.addAll([
              const PopupMenuDivider(),
              toMenuItem(
                ChipSetAction.selectAll,
                enabled: selectedItems.length < actionDelegate.allItems.length,
              ),
              toMenuItem(
                ChipSetAction.selectNone,
                enabled: selectedItems.isNotEmpty,
              ),
            ]);
          } else if (appMode == AppMode.main) {
            menuItems.addAll([
              toMenuItem(
                ChipSetAction.select,
                enabled: !widget.isEmpty,
              ),
              toMenuItem(ChipSetAction.map),
              toMenuItem(ChipSetAction.stats),
              toMenuItem(ChipSetAction.createAlbum),
            ]);
          }

          return menuItems;
        },
        onSelected: (action) {
          // wait for the popup menu to hide before proceeding with the action
          Future.delayed(Durations.popupMenuAnimation * timeDilation, () => applyAction(action));
        },
      ),
    ];
  }

  void _onActivityChange() {
    if (context.read<Selection<FilterGridItem<T>>>().isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
    }
  }

  void _goToSearch() {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          source: source,
        ),
      ),
    );
  }
}
