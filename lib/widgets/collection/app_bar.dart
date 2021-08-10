import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/collection_actions.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/app_shortcut_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/pedantic.dart';
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
      duration: Durations.iconAnimation,
      vsync: this,
    );
    _isSelectingNotifier.addListener(_onActivityChange);
    _canAddShortcutsLoader = AppShortcutService.canPin();
    _registerWidget(widget);
    WidgetsBinding.instance!.addPostFrameCallback((_) => _updateHeight());
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
    widget.collection.filterChangeNotifier.addListener(_updateHeight);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    widget.collection.filterChangeNotifier.removeListener(_updateHeight);
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
      return Selector<Selection<AvesEntry>, int>(
        selector: (context, selection) => selection.selection.length,
        builder: (context, count, child) => Text(context.l10n.collectionSelectionPageTitle(count)),
      );
    } else {
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
    }
  }

  List<Widget> _buildActions(bool isSelecting) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    return [
      if (!isSelecting && appMode.canSearch)
        CollectionSearchButton(
          source: source,
          parentCollection: collection,
        ),
      if (isSelecting)
        ...EntryActions.selection.map((action) => Selector<Selection<AvesEntry>, bool>(
              selector: (context, selection) => selection.selection.isEmpty,
              builder: (context, isEmpty, child) => IconButton(
                icon: Icon(action.getIcon()),
                onPressed: isEmpty ? null : () => _actionDelegate.onEntryActionSelected(context, action),
                tooltip: action.getText(context),
              ),
            )),
      FutureBuilder<bool>(
        future: _canAddShortcutsLoader,
        builder: (context, snapshot) {
          final canAddShortcuts = snapshot.data ?? false;
          return PopupMenuButton<CollectionAction>(
            key: const Key('appbar-menu-button'),
            itemBuilder: (context) {
              final groupable = collection.sortFactor == EntrySortFactor.date;
              final selection = context.read<Selection<AvesEntry>>();
              final isSelecting = selection.isSelecting;
              final selectedItems = selection.selection;
              final hasSelection = selectedItems.isNotEmpty;
              final hasItems = !collection.isEmpty;
              final otherViewEnabled = (!isSelecting && hasItems) || (isSelecting && hasSelection);

              return [
                _toMenuItem(
                  CollectionAction.sort,
                  key: const Key('menu-sort'),
                ),
                if (groupable)
                  _toMenuItem(
                    CollectionAction.group,
                    key: const Key('menu-group'),
                  ),
                if (appMode == AppMode.main) ...[
                  if (!isSelecting)
                    _toMenuItem(
                      CollectionAction.select,
                      enabled: hasItems,
                    ),
                  const PopupMenuDivider(),
                  if (isSelecting)
                    ...[
                      CollectionAction.copy,
                      CollectionAction.move,
                      CollectionAction.refreshMetadata,
                    ].map((v) => _toMenuItem(v, enabled: hasSelection)),
                  ...[
                    CollectionAction.map,
                    CollectionAction.stats,
                  ].map((v) => _toMenuItem(v, enabled: otherViewEnabled)),
                  if (!isSelecting && canAddShortcuts) ...[
                    const PopupMenuDivider(),
                    _toMenuItem(CollectionAction.addShortcut),
                  ],
                ],
                if (isSelecting) ...[
                  const PopupMenuDivider(),
                  _toMenuItem(
                    CollectionAction.selectAll,
                    enabled: selectedItems.length < collection.entryCount,
                  ),
                  _toMenuItem(
                    CollectionAction.selectNone,
                    enabled: hasSelection,
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

  PopupMenuItem<CollectionAction> _toMenuItem(CollectionAction action, {Key? key, bool enabled = true}) {
    return PopupMenuItem(
      key: key,
      value: action,
      enabled: enabled,
      child: MenuRow(
        text: action.getText(context),
        icon: action.getIcon(),
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

  void _updateHeight() {
    widget.appBarHeightNotifier.value = kToolbarHeight + (hasFilters ? FilterBar.preferredHeight : 0);
  }

  Future<void> _onCollectionActionSelected(CollectionAction action) async {
    switch (action) {
      case CollectionAction.copy:
      case CollectionAction.move:
      case CollectionAction.refreshMetadata:
      case CollectionAction.map:
      case CollectionAction.stats:
        _actionDelegate.onCollectionActionSelected(context, action);
        break;
      case CollectionAction.select:
        context.read<Selection<AvesEntry>>().select();
        break;
      case CollectionAction.selectAll:
        context.read<Selection<AvesEntry>>().addToSelection(collection.sortedEntries);
        break;
      case CollectionAction.selectNone:
        context.read<Selection<AvesEntry>>().clearSelection();
        break;
      case CollectionAction.addShortcut:
        unawaited(_showShortcutDialog(context));
        break;
      case CollectionAction.group:
        final value = await showDialog<EntryGroupFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<EntryGroupFactor>(
            initialValue: settings.collectionSectionFactor,
            options: {
              EntryGroupFactor.album: context.l10n.collectionGroupAlbum,
              EntryGroupFactor.month: context.l10n.collectionGroupMonth,
              EntryGroupFactor.day: context.l10n.collectionGroupDay,
              EntryGroupFactor.none: context.l10n.collectionGroupNone,
            },
            title: context.l10n.collectionGroupTitle,
          ),
        );
        // wait for the dialog to hide as applying the change may block the UI
        await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
        if (value != null) {
          settings.collectionSectionFactor = value;
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
      defaultName = sortedFilters.first.getLabel(context);
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
      ),
    );
  }
}
