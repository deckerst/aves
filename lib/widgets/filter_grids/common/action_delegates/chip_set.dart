import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/cover_selection_dialog.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

abstract class ChipSetActionDelegate<T extends CollectionFilter> with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  Iterable<FilterGridItem<T>> get allItems;

  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  TileLayout get tileLayout;

  set tileLayout(TileLayout tileLayout);

  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<T> selectedFilters,
  }) {
    final selectedItemCount = selectedFilters.length;
    final hasSelection = selectedFilters.isNotEmpty;
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
        return appMode.canNavigate && !isSelecting;
      case ChipSetAction.toggleTitleSearch:
        return !isSelecting;
      case ChipSetAction.createAlbum:
        return false;
      // browsing or selecting
      case ChipSetAction.map:
      case ChipSetAction.slideshow:
      case ChipSetAction.stats:
        return appMode == AppMode.main;
      // selecting (single/multiple filters)
      case ChipSetAction.delete:
        return false;
      case ChipSetAction.hide:
        return appMode == AppMode.main;
      case ChipSetAction.pin:
        return !hasSelection || !settings.pinnedFilters.containsAll(selectedFilters);
      case ChipSetAction.unpin:
        return hasSelection && settings.pinnedFilters.containsAll(selectedFilters);
      // selecting (single filter)
      case ChipSetAction.rename:
        return false;
      case ChipSetAction.setCover:
        return appMode == AppMode.main;
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
        return hasSelection;
      // selecting (single filter)
      case ChipSetAction.rename:
      case ChipSetAction.setCover:
        return selectedItemCount == 1;
    }
  }

  void onActionSelected(BuildContext context, Set<T> filters, ChipSetAction action) {
    switch (action) {
      // general
      case ChipSetAction.configureView:
        configureView(context);
        break;
      case ChipSetAction.select:
        context.read<Selection<FilterGridItem<T>>>().select();
        break;
      case ChipSetAction.selectAll:
        context.read<Selection<FilterGridItem<T>>>().addToSelection(allItems);
        break;
      case ChipSetAction.selectNone:
        context.read<Selection<FilterGridItem<T>>>().clearSelection();
        break;
      // browsing
      case ChipSetAction.search:
        _goToSearch(context);
        break;
      case ChipSetAction.toggleTitleSearch:
        context.read<Query>().toggle();
        break;
      case ChipSetAction.createAlbum:
        break;
      // browsing or selecting
      case ChipSetAction.map:
        _goToMap(context, filters);
        break;
      case ChipSetAction.slideshow:
        _goToSlideshow(context, filters);
        break;
      case ChipSetAction.stats:
        _goToStats(context, filters);
        break;
      // selecting (single/multiple filters)
      case ChipSetAction.delete:
        break;
      case ChipSetAction.hide:
        _hide(context, filters);
        break;
      case ChipSetAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..addAll(filters);
        _browse(context);
        break;
      case ChipSetAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..removeAll(filters);
        _browse(context);
        break;
      // selecting (single filter)
      case ChipSetAction.rename:
        break;
      case ChipSetAction.setCover:
        _setCover(context, filters.first);
        break;
    }
  }

  void _browse(BuildContext context) => context.read<Selection<FilterGridItem<T>>>().browse();

  Iterable<AvesEntry> _selectedEntries(BuildContext context, Set<dynamic> filters) {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;
    return filters.isEmpty ? visibleEntries : visibleEntries.where((entry) => filters.any((f) => f.test(entry)));
  }

  Future<void> configureView(BuildContext context) async {
    final initialValue = Tuple3(
      sortFactor,
      null,
      tileLayout,
    );
    final value = await showDialog<Tuple3<ChipSortFactor?, void, TileLayout?>>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return TileViewDialog<ChipSortFactor, void, TileLayout>(
          initialValue: initialValue,
          sortOptions: {
            ChipSortFactor.date: l10n.sortByDate,
            ChipSortFactor.name: l10n.sortByName,
            ChipSortFactor.count: l10n.sortByItemCount,
            ChipSortFactor.size: l10n.sortBySize,
          },
          layoutOptions: {
            TileLayout.grid: l10n.tileLayoutGrid,
            TileLayout.list: l10n.tileLayoutList,
          },
        );
      },
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (value != null && initialValue != value) {
      sortFactor = value.item1!;
      tileLayout = value.item3!;
    }
  }

  void _goToMap(BuildContext context, Set<T> filters) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(
          collection: CollectionLens(
            source: context.read<CollectionSource>(),
            fixedSelection: _selectedEntries(context, filters).where((entry) => entry.hasGps).toList(),
          ),
        ),
      ),
    );
  }

  void _goToSlideshow(BuildContext context, Set<T> filters) {
    Navigator.push(
      context,
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
    Navigator.push(
      context,
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
    Navigator.push(
      context,
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
      builder: (context) {
        return AvesDialog(
          content: Text(context.l10n.hideFilterConfirmationDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.hideButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    settings.changeFilterVisibility(filters, false);

    _browse(context);
  }

  void _setCover(BuildContext context, T filter) async {
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

    _browse(context);
  }
}
