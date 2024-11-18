import 'package:aves/app_mode.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/or.dart';
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
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/cover_selection_dialog.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
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
      case ChipSetAction.configureView:
        return true;
      case ChipSetAction.select:
        return appMode.canSelectFilter && !isSelecting;
      case ChipSetAction.selectAll:
        return isSelecting && selectedItemCount < itemCount;
      case ChipSetAction.selectNone:
        return isSelecting && selectedItemCount == itemCount;
      // browsing
      case ChipSetAction.search:
        return !useTvLayout && appMode.canNavigate && !isSelecting;
      case ChipSetAction.toggleTitleSearch:
        return !useTvLayout && !isSelecting;
      case ChipSetAction.createAlbum:
      case ChipSetAction.createVault:
        return false;
      // browsing or selecting
      case ChipSetAction.map:
      case ChipSetAction.slideshow:
      case ChipSetAction.stats:
        return isMain;
      // selecting (single/multiple filters)
      case ChipSetAction.hide:
        return isMain;
      case ChipSetAction.pin:
        return isMain && (!hasSelection || !settings.pinnedFilters.containsAll(selectedFilters));
      case ChipSetAction.unpin:
        return isMain && (hasSelection && settings.pinnedFilters.containsAll(selectedFilters));
      case ChipSetAction.showCollection:
        return appMode.canNavigate;
      case ChipSetAction.delete:
      case ChipSetAction.lockVault:
      case ChipSetAction.showCountryStates:
        return false;
      // selecting (single filter)
      case ChipSetAction.setCover:
        return isMain;
      case ChipSetAction.rename:
      case ChipSetAction.configureVault:
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
      case ChipSetAction.configureView:
      case ChipSetAction.select:
      case ChipSetAction.selectAll:
      case ChipSetAction.selectNone:
      // browsing
      case ChipSetAction.search:
      case ChipSetAction.toggleTitleSearch:
      case ChipSetAction.createAlbum:
      case ChipSetAction.createVault:
        return true;
      // browsing or selecting
      case ChipSetAction.map:
      case ChipSetAction.slideshow:
      case ChipSetAction.stats:
        return (!isSelecting && hasItems) || (isSelecting && hasSelection);
      // selecting (single/multiple filters)
      case ChipSetAction.delete:
      case ChipSetAction.hide:
      case ChipSetAction.pin:
      case ChipSetAction.unpin:
      case ChipSetAction.lockVault:
      case ChipSetAction.showCountryStates:
      case ChipSetAction.showCollection:
        return hasSelection;
      // selecting (single filter)
      case ChipSetAction.rename:
      case ChipSetAction.setCover:
      case ChipSetAction.configureVault:
        return selectedItemCount == 1;
    }
  }

  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // general
      case ChipSetAction.configureView:
        configureView(context);
      case ChipSetAction.select:
        context.read<Selection<FilterGridItem<T>>>().select();
      case ChipSetAction.selectAll:
        context.read<Selection<FilterGridItem<T>>>().addToSelection(allItems);
      case ChipSetAction.selectNone:
        context.read<Selection<FilterGridItem<T>>>().clearSelection();
      // browsing
      case ChipSetAction.search:
        _goToSearch(context);
      case ChipSetAction.toggleTitleSearch:
        context.read<Query>().toggle();
      case ChipSetAction.createAlbum:
      case ChipSetAction.createVault:
        break;
      // browsing or selecting
      case ChipSetAction.map:
        _goToMap(context);
      case ChipSetAction.slideshow:
        _goToSlideshow(context);
      case ChipSetAction.stats:
        _goToStats(context);
      // selecting (single/multiple filters)
      case ChipSetAction.hide:
        _hide(context);
      case ChipSetAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..addAll(getSelectedFilters(context));
        browse(context);
      case ChipSetAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..removeAll(getSelectedFilters(context));
        browse(context);
      case ChipSetAction.showCollection:
        _goToCollection(context);
      case ChipSetAction.delete:
      case ChipSetAction.lockVault:
      case ChipSetAction.showCountryStates:
        break;
      // selecting (single filter)
      case ChipSetAction.setCover:
        _setCover(context);
      case ChipSetAction.rename:
      case ChipSetAction.configureVault:
        break;
    }
  }

  void browse(BuildContext context) => context.read<Selection<FilterGridItem<T>>?>()?.browse();

  Set<T> getSelectedFilters(BuildContext context) {
    final selection = context.read<Selection<FilterGridItem<T>>>();
    return selection.isSelecting ? selection.selectedItems.map((v) => v.filter).toSet() : {};
  }

  Iterable<AvesEntry> _selectedEntries(BuildContext context) {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;
    final filters = getSelectedFilters(context);
    return filters.isEmpty ? visibleEntries : visibleEntries.where((entry) => filters.any((f) => f.test(entry)));
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

  Future<void> _goToCollection(context) async {
    final filters = getSelectedFilters(context);
    if (filters.isEmpty) return;

    final filter = filters.length > 1 ? OrFilter(filters) : filters.first;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(context.l10n.hideFilterConfirmationDialogMessage),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(context.l10n.hideButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.confirmationRouteName),
    );
    if (confirmed == null || !confirmed) return;

    final filters = getSelectedFilters(context);
    settings.changeFilterVisibility(filters, false);

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

    if (filter is AlbumFilter) {
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
