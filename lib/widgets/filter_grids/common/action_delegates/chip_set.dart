import 'package:aves/app_mode.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/cover_selection_dialog.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/collection_search_delegate.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

abstract class ChipSetActionDelegate<T extends CollectionFilter> with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, VaultAwareMixin {
  Iterable<FilterGridItem<T>> get allItems;

  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  bool get sortReverse;

  set sortReverse(bool value);

  TileLayout get tileLayout;

  set tileLayout(TileLayout tileLayout);

  static const sortOptions = [
    ChipSortFactor.date,
    ChipSortFactor.name,
    ChipSortFactor.count,
    ChipSortFactor.size,
  ];

  static const albumSortOptions = [
    ...sortOptions,
    ChipSortFactor.path,
  ];

  static const layoutOptions = [
    TileLayout.mosaic,
    TileLayout.grid,
    TileLayout.list,
  ];

  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<T> selectedFilters,
  }) {
    final selectedItemCount = selectedFilters.length;
    final hasSelection = selectedFilters.isNotEmpty;
    final isMain = appMode == AppMode.main;
    final useTvLayout = settings.useTvLayout;
    switch (action) {
      // general
      case .configureView:
        return true;
      case .select:
        return appMode.canSelectFilter && !isSelecting;
      case .selectAll:
        return isSelecting && selectedItemCount < itemCount;
      case .selectNone:
        return isSelecting && selectedItemCount == itemCount;
      // browsing
      case .search:
        return !useTvLayout && appMode.canNavigate && !isSelecting;
      case .toggleTitleSearch:
        return !useTvLayout && !isSelecting;
      case .createGroup:
      case .createAlbum:
      case .createVault:
        return false;
      // browsing or selecting
      case .map:
      case .slideshow:
      case .stats:
        return isMain;
      // selecting (single/multiple filters)
      case .hide:
        return isMain;
      case .pin:
        return isMain && (!hasSelection || !settings.pinnedFilters.containsAll(selectedFilters));
      case .unpin:
        return isMain && (hasSelection && settings.pinnedFilters.containsAll(selectedFilters));
      case .showCollection:
        return appMode.canNavigate;
      case .delete:
      case .remove:
      case .group:
      case .lockVault:
      case .showCountryStates:
        return false;
      // selecting (single filter)
      case .setCover:
        return isMain;
      case .rename:
      case .configureVault:
        return false;
    }
  }

  bool canApply(
    ChipSetAction action, {
    required bool isSelecting,
    required int itemCount,
    required Set<T> selectedFilters,
  }) {
    final selectedItemCount = selectedFilters.length;
    final hasItems = itemCount > 0;
    final hasSelection = selectedItemCount > 0;

    switch (action) {
      // general
      case .select:
        return hasItems;
      case .configureView:
      case .selectAll:
      case .selectNone:
      // browsing
      case .search:
      case .toggleTitleSearch:
      case .createGroup:
      case .createAlbum:
      case .createVault:
        return true;
      // browsing or selecting
      case .map:
      case .slideshow:
      case .stats:
        return (!isSelecting && hasItems) || (isSelecting && hasSelection);
      // selecting (single/multiple filters)
      case .delete:
      case .remove:
      case .hide:
      case .pin:
      case .unpin:
      case .group:
      case .lockVault:
      case .showCountryStates:
      case .showCollection:
        return hasSelection;
      // selecting (single filter)
      case .rename:
      case .setCover:
      case .configureVault:
        return selectedItemCount == 1;
    }
  }

  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // general
      case .configureView:
        configureView(context);
      case .select:
        context.read<Selection<FilterGridItem<T>>>().select();
      case .selectAll:
        context.read<Selection<FilterGridItem<T>>>().addToSelection(allItems);
      case .selectNone:
        context.read<Selection<FilterGridItem<T>>>().clearSelection();
      // browsing
      case .search:
        _goToSearch(context);
      case .toggleTitleSearch:
        final routeName = context.currentRouteName!;
        settings.setShowTitleQuery(routeName, !settings.getShowTitleQuery(routeName));
        context.read<Query>().toggle();
      case .createGroup:
      case .createAlbum:
      case .createVault:
        break;
      // browsing or selecting
      case .map:
        _goToMap(context);
      case .slideshow:
        _goToSlideshow(context);
      case .stats:
        _goToStats(context);
      // selecting (single/multiple filters)
      case .hide:
        _hide(context);
      case .pin:
        settings.pinnedFilters = settings.pinnedFilters..addAll(getSelectedFilters(context));
        browse(context);
      case .unpin:
        settings.pinnedFilters = settings.pinnedFilters..removeAll(getSelectedFilters(context));
        browse(context);
      case .showCollection:
        _goToCollection(context);
      case .delete:
      case .remove:
      case .group:
      case .lockVault:
      case .showCountryStates:
        break;
      // selecting (single filter)
      case .setCover:
        _setCover(context);
      case .rename:
      case .configureVault:
        break;
    }
  }

  void browse(BuildContext context) {
    context.read<Selection<FilterGridItem<T>>?>()?.browse();
  }

  Set<T> getSelectedFilters(BuildContext context) {
    final selection = context.read<Selection<FilterGridItem<T>>>();
    return selection.isSelecting ? selection.selectedItems.map((v) => v.filter).toSet() : {};
  }

  Iterable<AvesEntry> _selectedEntries(BuildContext context) {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;

    final filters = <CollectionFilter>{};
    // use user selected filters, if any
    filters.addAll(getSelectedFilters(context));

    if (filters.isEmpty) {
      // use current group filters, if any
      final groupUri = context.read<FilterGroupNotifier?>()?.value;
      if (groupUri != null) {
        final grouping = FilterGrouping.forUri(groupUri);
        if (grouping != null) {
          final groupContent = grouping.getDirectChildren(groupUri);
          filters.addAll(groupContent);
        }
      }
    }

    if (filters.isNotEmpty) {
      return visibleEntries.where((entry) => filters.any((f) => f.test(entry)));
    }

    // default to all content
    return visibleEntries;
  }

  Future<void> configureView(BuildContext context) async {
    final initialValue = (
      sortFactor,
      null,
      tileLayout,
      sortReverse,
    );
    final extentController = context.read<TileExtentController>();
    final value = await showDialog<(ChipSortFactor?, void, TileLayout?, bool)>(
      context: context,
      builder: (context) {
        return TileViewDialog<ChipSortFactor, void, TileLayout>(
          initialValue: initialValue,
          sortOptions: sortOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          layoutOptions: layoutOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          sortOrder: (factor, reverse) => factor.getOrderName(context, reverse),
          tileExtentController: extentController,
        );
      },
      routeSettings: const RouteSettings(name: TileViewDialog.routeName),
    );
    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
    if (value != null && initialValue != value) {
      sortFactor = value.$1!;
      tileLayout = value.$3!;
      sortReverse = value.$4;
    }
  }

  Future<void> _goToCollection(BuildContext context) async {
    final filters = getSelectedFilters(context);
    if (filters.isEmpty) return;

    final filter = filters.length > 1 ? SetOrFilter(filters) : filters.first;
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: context.read<CollectionSource>(),
          filters: {filter},
        ),
      ),
    );
  }

  Future<void> _goToMap(BuildContext context) async {
    final mapCollection = CollectionLens(
      source: context.read<CollectionSource>(),
      fixedSelection: _selectedEntries(context).where((entry) => entry.hasGps).toList(),
    );
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(collection: mapCollection),
      ),
    );
  }

  Future<void> _goToSlideshow(BuildContext context) async {
    final entries = _selectedEntries(context).toList();
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: SlideshowPage.routeName),
        builder: (context) {
          return SlideshowPage(
            collection: CollectionLens(
              source: context.read<CollectionSource>(),
              fixedSelection: entries,
            ),
          );
        },
      ),
    );
  }

  Future<void> _goToStats(BuildContext context) async {
    final entries = _selectedEntries(context).toSet();
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: StatsPage.routeName),
        builder: (context) {
          return StatsPage(
            entries: entries,
            source: context.read<CollectionSource>(),
          );
        },
      ),
    );
  }

  Future<void> _goToSearch(BuildContext context) async {
    await Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          searchFieldStyle: Themes.searchFieldStyle(context),
          source: context.read<CollectionSource>(),
        ),
      ),
    );
  }

  Future<void> _hide(BuildContext context) async {
    final l10n = context.l10n;

    if (!await showConfirmationDialog(
      context: context,
      message: l10n.hideFilterConfirmationDialogMessage,
      ok: l10n.hideButtonLabel,
    )) {
      return;
    }

    final filters = getSelectedFilters(context);
    if (!await unlockFilters(context, filters)) return;

    settings.changeFilterVisibility(filters, false);
    lockFilters(filters);

    browse(context);
  }

  void _setCover(BuildContext context) async {
    final filters = getSelectedFilters(context);
    if (filters.isEmpty) return;

    final filter = filters.first;
    if (!await unlockFilter(context, filter)) return;

    final existingCover = covers.of(filter);
    final entryId = existingCover?.$1;
    final customEntry = entryId != null ? context.read<CollectionSource>().visibleEntries.firstWhereOrNull((entry) => entry.id == entryId) : null;
    final selectedCover = await showDialog<(AvesEntry?, String?, Color?)>(
      context: context,
      builder: (context) => CoverSelectionDialog(
        filter: filter,
        customEntry: customEntry,
        customPackage: existingCover?.$2,
        customColor: existingCover?.$3,
      ),
      routeSettings: const RouteSettings(name: CoverSelectionDialog.routeName),
    );
    if (selectedCover == null) return;

    if (filter is StoredAlbumFilter) {
      context.read<AvesColorsData>().clearAppColor(filter.album);
    }

    final (selectedEntry, selectedPackage, selectedColor) = selectedCover;
    await covers.set(
      filter: filter,
      entryId: selectedEntry?.id,
      packageName: selectedPackage,
      color: selectedColor,
    );

    browse(context);
  }
}
