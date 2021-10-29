import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/collection/filter_bar.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/search/search_button.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CollectionAppBar extends StatefulWidget {
  final ValueNotifier<double> appBarHeightNotifier;
  final CollectionLens collection;

  const CollectionAppBar({
    Key? key,
    required this.appBarHeightNotifier,
    required this.collection,
  }) : super(key: key);

  @override
  _CollectionAppBarState createState() => _CollectionAppBarState();
}

class _CollectionAppBarState extends State<CollectionAppBar> with SingleTickerProviderStateMixin {
  final EntrySetActionDelegate _actionDelegate = EntrySetActionDelegate();
  late AnimationController _browseToSelectAnimation;
  late Future<bool> _canAddShortcutsLoader;
  final ValueNotifier<bool> _isSelectingNotifier = ValueNotifier(false);

  CollectionLens get collection => widget.collection;

  CollectionSource get source => collection.source;

  bool get hasFilters => collection.filters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _browseToSelectAnimation = AnimationController(
      duration: context.read<DurationsData>().iconAnimation,
      vsync: this,
    );
    _isSelectingNotifier.addListener(_onActivityChange);
    _canAddShortcutsLoader = androidAppService.canPinToHomeScreen();
    _registerWidget(widget);
    WidgetsBinding.instance!.addPostFrameCallback((_) => _onFilterChanged());
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
    _isSelectingNotifier.removeListener(_onActivityChange);
    _browseToSelectAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(CollectionAppBar widget) {
    widget.collection.filterChangeNotifier.addListener(_onFilterChanged);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    widget.collection.filterChangeNotifier.removeListener(_onFilterChanged);
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    return Selector<Selection<AvesEntry>, bool>(
      selector: (context, selection) => selection.isSelecting,
      builder: (context, isSelecting, child) {
        _isSelectingNotifier.value = isSelecting;
        return AnimatedBuilder(
          animation: collection.filterChangeNotifier,
          builder: (context, child) {
            final removableFilters = appMode != AppMode.pickInternal;
            return SliverAppBar(
              leading: appMode.hasDrawer ? _buildAppBarLeading(isSelecting) : null,
              title: _buildAppBarTitle(isSelecting),
              actions: _buildActions(isSelecting),
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

  Widget _buildAppBarLeading(bool isSelecting) {
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

  Widget? _buildAppBarTitle(bool isSelecting) {
    final l10n = context.l10n;

    if (isSelecting) {
      return Selector<Selection<AvesEntry>, int>(
        selector: (context, selection) => selection.selectedItems.length,
        builder: (context, count, child) => Text(l10n.collectionSelectionPageTitle(count)),
      );
    } else {
      final appMode = context.watch<ValueNotifier<AppMode>>().value;
      Widget title = Text(appMode.isPicking ? l10n.collectionPickPageTitle : l10n.collectionPageTitle);
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
    }
  }

  List<Widget> _buildActions(bool isSelecting) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    final selectionQuickActions = settings.collectionSelectionQuickActions;
    return [
      if (!isSelecting && appMode.canSearch)
        CollectionSearchButton(
          source: source,
          parentCollection: collection,
        ),
      if (isSelecting)
        ...selectionQuickActions.map((action) => Selector<Selection<AvesEntry>, bool>(
              selector: (context, selection) => selection.selectedItems.isEmpty,
              builder: (context, isEmpty, child) => IconButton(
                icon: action.getIcon(),
                onPressed: isEmpty ? null : () => _onCollectionActionSelected(action),
                tooltip: action.getText(context),
              ),
            )),
      FutureBuilder<bool>(
        future: _canAddShortcutsLoader,
        builder: (context, snapshot) {
          final canAddShortcuts = snapshot.data ?? false;
          return MenuIconTheme(
            child: PopupMenuButton<EntrySetAction>(
              // key is expected by test driver
              key: const Key('appbar-menu-button'),
              itemBuilder: (context) {
                final groupable = collection.sortFactor == EntrySortFactor.date;
                final selection = context.read<Selection<AvesEntry>>();
                final isSelecting = selection.isSelecting;
                final selectedItems = selection.selectedItems;
                final hasSelection = selectedItems.isNotEmpty;
                final hasItems = !collection.isEmpty;
                final otherViewEnabled = (!isSelecting && hasItems) || (isSelecting && hasSelection);

                return [
                  _toMenuItem(EntrySetAction.sort),
                  if (groupable) _toMenuItem(EntrySetAction.group),
                  if (appMode == AppMode.main) ...[
                    if (!isSelecting)
                      _toMenuItem(
                        EntrySetAction.select,
                        enabled: hasItems,
                      ),
                    const PopupMenuDivider(),
                    if (isSelecting) ...[
                      ...EntrySetActions.selection.where((v) => !selectionQuickActions.contains(v)).map((v) => _toMenuItem(v, enabled: hasSelection)),
                      PopupMenuItem(
                        enabled: hasSelection,
                        padding: EdgeInsets.zero,
                        child: PopupMenuItemExpansionPanel<EntrySetAction>(
                          enabled: hasSelection,
                          icon: AIcons.edit,
                          title: context.l10n.collectionActionEdit,
                          items: [
                            _toMenuItem(EntrySetAction.editDate, enabled: hasSelection),
                          ],
                        ),
                      ),
                    ],
                    if (!isSelecting)
                      ...[
                        EntrySetAction.map,
                        EntrySetAction.stats,
                      ].map((v) => _toMenuItem(v, enabled: otherViewEnabled)),
                    if (!isSelecting && canAddShortcuts) ...[
                      const PopupMenuDivider(),
                      _toMenuItem(EntrySetAction.addShortcut),
                    ],
                  ],
                  if (isSelecting) ...[
                    const PopupMenuDivider(),
                    _toMenuItem(
                      EntrySetAction.selectAll,
                      enabled: selectedItems.length < collection.entryCount,
                    ),
                    _toMenuItem(
                      EntrySetAction.selectNone,
                      enabled: hasSelection,
                    ),
                  ]
                ];
              },
              onSelected: (action) async {
                // wait for the popup menu to hide before proceeding with the action
                await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                await _onCollectionActionSelected(action);
              },
            ),
          );
        },
      ),
    ];
  }

  PopupMenuItem<EntrySetAction> _toMenuItem(EntrySetAction action, {bool enabled = true}) {
    return PopupMenuItem(
      // key is expected by test driver (e.g. 'menu-sort', 'menu-group', 'menu-map')
      key: Key('menu-${action.toString().substring('EntrySetAction.'.length)}'),
      value: action,
      enabled: enabled,
      child: MenuRow(text: action.getText(context), icon: action.getIcon()),
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
    widget.appBarHeightNotifier.value = kToolbarHeight + (hasFilters ? FilterBar.preferredHeight : 0);

    if (hasFilters) {
      final filters = collection.filters;
      final selection = context.read<Selection<AvesEntry>>();
      if (selection.isSelecting) {
        final toRemove = selection.selectedItems.where((entry) => !filters.every((f) => f.test(entry))).toSet();
        selection.removeFromSelection(toRemove);
      }
    }
  }

  Future<void> _onCollectionActionSelected(EntrySetAction action) async {
    switch (action) {
      case EntrySetAction.share:
      case EntrySetAction.delete:
      case EntrySetAction.copy:
      case EntrySetAction.move:
      case EntrySetAction.rescan:
      case EntrySetAction.map:
      case EntrySetAction.stats:
      case EntrySetAction.editDate:
        _actionDelegate.onActionSelected(context, action);
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
      case EntrySetAction.addShortcut:
        unawaited(_showShortcutDialog(context));
        break;
      case EntrySetAction.group:
        final value = await showDialog<EntryGroupFactor>(
          context: context,
          builder: (context) {
            final l10n = context.l10n;
            return AvesSelectionDialog<EntryGroupFactor>(
              initialValue: settings.collectionSectionFactor,
              options: {
                EntryGroupFactor.album: l10n.collectionGroupAlbum,
                EntryGroupFactor.month: l10n.collectionGroupMonth,
                EntryGroupFactor.day: l10n.collectionGroupDay,
                EntryGroupFactor.none: l10n.collectionGroupNone,
              },
              title: l10n.collectionGroupTitle,
            );
          },
        );
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
        if (value != null) {
          settings.collectionSectionFactor = value;
        }
        break;
      case EntrySetAction.sort:
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
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
        if (value != null) {
          settings.collectionSortFactor = value;
        }
        break;
    }
  }

  Future<void> _showShortcutDialog(BuildContext context) async {
    final filters = collection.filters;
    String? defaultName;
    if (filters.isNotEmpty) {
      // we compute the default name beforehand
      // because some filter labels need localization
      final sortedFilters = List<CollectionFilter>.from(filters)..sort();
      defaultName = sortedFilters.first.getLabel(context).replaceAll('\n', ' ');
    }
    final result = await showDialog<Tuple2<AvesEntry?, String>>(
      context: context,
      builder: (context) => AddShortcutDialog(
        collection: collection,
        defaultName: defaultName ?? '',
      ),
    );
    if (result == null) return;

    final coverEntry = result.item1;
    final name = result.item2;
    if (name.isEmpty) return;

    unawaited(androidAppService.pinToHomeScreen(name, coverEntry, filters));
  }

  void _goToSearch() {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          source: collection.source,
          parentCollection: collection,
        ),
      ),
    );
  }
}
