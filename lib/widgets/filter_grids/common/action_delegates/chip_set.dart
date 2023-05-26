import 'package:aves/app_mode.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/view/view.dart';
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
import 'package:tuple/tuple.dart';

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
        return !hasSelection || !settings.pinnedFilters.containsAll(selectedFilters);
      case ChipSetAction.unpin:
        return hasSelection && settings.pinnedFilters.containsAll(selectedFilters);
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
        return hasSelection;
      // selecting (single filter)
      case ChipSetAction.rename:
      case ChipSetAction.setCover:
      case ChipSetAction.configureVault:
        return selectedItemCount == 1;
    }
  }

  void onActionSelected(BuildContext context, Set<T> filters, ChipSetAction action) {
    reportService.log('$action');
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
        _goToMap(context, filters);
      case ChipSetAction.slideshow:
        _goToSlideshow(context, filters);
      case ChipSetAction.stats:
        _goToStats(context, filters);
      // selecting (single/multiple filters)
      case ChipSetAction.hide:
        _hide(context, filters);
      case ChipSetAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..addAll(filters);
        browse(context);
      case ChipSetAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..removeAll(filters);
        browse(context);
      case ChipSetAction.delete:
      case ChipSetAction.lockVault:
      case ChipSetAction.showCountryStates:
        break;
      // selecting (single filter)
      case ChipSetAction.setCover:
        _setCover(context, filters.first);
      case ChipSetAction.rename:
      case ChipSetAction.configureVault:
        break;
    }
  }

  void browse(BuildContext context) => context.read<Selection<FilterGridItem<T>>?>()?.browse();

  Iterable<AvesEntry> _selectedEntries(BuildContext context, Set<dynamic> filters) {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;
    return filters.isEmpty ? visibleEntries : visibleEntries.where((entry) => filters.any((f) => f.test(entry)));
  }

  Future<void> configureView(BuildContext context) async {
    final initialValue = Tuple4(
      sortFactor,
      null,
      tileLayout,
      sortReverse,
    );
    final extentController = context.read<TileExtentController>();
    final value = await showDialog<Tuple4<ChipSortFactor?, void, TileLayout?, bool>>(
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
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (value != null && initialValue != value) {
      sortFactor = value.item1!;
      tileLayout = value.item3!;
      sortReverse = value.item4;
    }
  }

  Future<void> _goToMap(BuildContext context, Set<T> filters) async {
    final mapCollection = CollectionLens(
      source: context.read<CollectionSource>(),
      fixedSelection: _selectedEntries(context, filters).where((entry) => entry.hasGps).toList(),
    );
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(collection: mapCollection),
      ),
    );
    mapCollection.dispose();
  }

  void _goToSlideshow(BuildContext context, Set<T> filters) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: SlideshowPage.routeName),
        builder: (context) {
          return SlideshowPage(
            collection: CollectionLens(
              source: context.read<CollectionSource>(),
              fixedSelection: _selectedEntries(context, filters).toList(),
            ),
          );
        },
      ),
    );
  }

  void _goToStats(BuildContext context, Set<T> filters) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: StatsPage.routeName),
        builder: (context) {
          return StatsPage(
            entries: _selectedEntries(context, filters).toSet(),
            source: context.read<CollectionSource>(),
          );
        },
      ),
    );
  }

  void _goToSearch(BuildContext context) {
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          source: context.read<CollectionSource>(),
        ),
      ),
    );
  }

  Future<void> _hide(BuildContext context, Set<T> filters) async {
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

    settings.changeFilterVisibility(filters, false);

    browse(context);
  }

  void _setCover(BuildContext context, T filter) async {
    if (!await unlockFilter(context, filter)) return;

    final existingCover = covers.of(filter);
    final entryId = existingCover?.item1;
    final customEntry = entryId != null ? context.read<CollectionSource>().visibleEntries.firstWhereOrNull((entry) => entry.id == entryId) : null;
    final selectedCover = await showDialog<Tuple3<AvesEntry?, String?, Color?>>(
      context: context,
      builder: (context) => CoverSelectionDialog(
        filter: filter,
        customEntry: customEntry,
        customPackage: existingCover?.item2,
        customColor: existingCover?.item3,
      ),
      routeSettings: const RouteSettings(name: CoverSelectionDialog.routeName),
    );
    if (selectedCover == null) return;

    if (filter is AlbumFilter) {
      context.read<AvesColorsData>().clearAppColor(filter.album);
    }

    final selectedEntry = selectedCover.item1;
    final selectedPackage = selectedCover.item2;
    final selectedColor = selectedCover.item3;
    await covers.set(
      filter: filter,
      entryId: selectedEntry?.id,
      packageName: selectedPackage,
      color: selectedColor,
    );

    browse(context);
  }
}
