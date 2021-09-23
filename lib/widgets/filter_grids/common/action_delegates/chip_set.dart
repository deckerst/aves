import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/dialogs/cover_selection_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

abstract class ChipSetActionDelegate<T extends CollectionFilter> with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  Iterable<FilterGridItem<T>> get allItems;

  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  bool isValid(Set<T> filters, ChipSetAction action) {
    final hasSelection = filters.isNotEmpty;
    switch (action) {
      case ChipSetAction.createAlbum:
      case ChipSetAction.delete:
      case ChipSetAction.rename:
        return false;
      case ChipSetAction.pin:
        return !hasSelection || !settings.pinnedFilters.containsAll(filters);
      case ChipSetAction.unpin:
        return hasSelection && settings.pinnedFilters.containsAll(filters);
      default:
        return true;
    }
  }

  bool canApply(Set<T> filters, ChipSetAction action) {
    switch (action) {
      // general
      case ChipSetAction.sort:
      case ChipSetAction.group:
      case ChipSetAction.select:
      case ChipSetAction.selectAll:
      case ChipSetAction.selectNone:
      case ChipSetAction.map:
      case ChipSetAction.stats:
      case ChipSetAction.createAlbum:
        return true;
      // single/multiple filters
      case ChipSetAction.delete:
      case ChipSetAction.hide:
      case ChipSetAction.pin:
      case ChipSetAction.unpin:
        return filters.isNotEmpty;
      // single filter
      case ChipSetAction.rename:
      case ChipSetAction.setCover:
        return filters.length == 1;
    }
  }

  void onActionSelected(BuildContext context, Set<T> filters, ChipSetAction action) {
    switch (action) {
      // general
      case ChipSetAction.sort:
        _showSortDialog(context);
        break;
      case ChipSetAction.map:
        _goToMap(context, filters);
        break;
      case ChipSetAction.stats:
        _goToStats(context, filters);
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
      // single/multiple filters
      case ChipSetAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..addAll(filters);
        break;
      case ChipSetAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..removeAll(filters);
        break;
      case ChipSetAction.hide:
        _hide(context, filters);
        break;
      // single filter
      case ChipSetAction.setCover:
        _showCoverSelectionDialog(context, filters.first);
        break;
      default:
        break;
    }
  }

  Iterable<AvesEntry> _selectedEntries(BuildContext context, Set<dynamic> filters) {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;
    return filters.isEmpty ? visibleEntries : visibleEntries.where((entry) => filters.any((f) => f.test(entry)));
  }

  Future<void> _showSortDialog(BuildContext context) async {
    final factor = await showDialog<ChipSortFactor>(
      context: context,
      builder: (context) => AvesSelectionDialog<ChipSortFactor>(
        initialValue: sortFactor,
        options: {
          ChipSortFactor.date: context.l10n.chipSortDate,
          ChipSortFactor.name: context.l10n.chipSortName,
          ChipSortFactor.count: context.l10n.chipSortCount,
        },
        title: context.l10n.chipSortTitle,
      ),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (factor != null) {
      sortFactor = factor;
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

  Future<void> _hide(BuildContext context, Set<T> filters) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
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

    final source = context.read<CollectionSource>();
    source.changeFilterVisibility(filters, false);
  }

  void _showCoverSelectionDialog(BuildContext context, T filter) async {
    final contentId = covers.coverContentId(filter);
    final customEntry = context.read<CollectionSource>().visibleEntries.firstWhereOrNull((entry) => entry.contentId == contentId);
    final coverSelection = await showDialog<Tuple2<bool, AvesEntry?>>(
      context: context,
      builder: (context) => CoverSelectionDialog(
        filter: filter,
        customEntry: customEntry,
      ),
    );
    if (coverSelection == null) return;

    final isCustom = coverSelection.item1;
    await covers.set(filter, isCustom ? coverSelection.item2?.contentId : null);
  }
}
