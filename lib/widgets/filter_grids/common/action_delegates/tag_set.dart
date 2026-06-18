import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/grouping/convert.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/tag_pick_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagChipSetActionDelegate extends ChipSetActionDelegate<TagBaseFilter> {
  final Iterable<FilterGridItem<TagBaseFilter>> _items;

  TagChipSetActionDelegate(Iterable<FilterGridItem<TagBaseFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<TagBaseFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.tagSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.tagSortFactor = factor;

  @override
  bool get sortReverse => settings.tagSortReverse;

  @override
  set sortReverse(bool value) => settings.tagSortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(TagListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(TagListPage.routeName, tileLayout);

  @override
  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<TagBaseFilter> selectedFilters,
  }) {
    final isMain = appMode == AppMode.main;
    final useTvLayout = settings.useTvLayout;

    switch (action) {
      case .createGroup:
        return true;
      case .group:
        return isMain && isSelecting && !useTvLayout;
      case .remove:
        return isMain && isSelecting && !settings.isReadOnly && (selectedFilters.isEmpty || selectedFilters.every((v) => v is TagFilter));
      default:
        return super.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  bool canApply(
    ChipSetAction action, {
    required bool isSelecting,
    required int itemCount,
    required Set<TagBaseFilter> selectedFilters,
  }) {
    switch (action) {
      case .delete:
        return selectedFilters.isNotEmpty && selectedFilters.every((v) => v is TagFilter);
      default:
        return super.canApply(
          action,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // single/multiple filters
      case .remove:
        _remove(context);
      case .group:
        _group(context);
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  Future<void> _remove(BuildContext context) async {
    final l10n = context.l10n;

    if (!await showConfirmationDialog(
      context: context,
      message: l10n.genericDangerWarningDialogMessage,
      ok: l10n.applyButtonLabel,
    )) {
      return;
    }

    final filters = getSelectedFilters(context).whereType<TagFilter>().toSet();
    final source = context.read<CollectionSource>();

    await EntrySetActionDelegate().removeTags(
      context,
      entries: source.visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet(),
      tags: filters.map((v) => v.tag).toSet(),
    );

    browse(context);
  }

  Future<void> _group(BuildContext context) async {
    final filters = getSelectedFilters(context);
    final childrenUris = filters.map(GroupingConversion.filterToUri).nonNulls.toSet();

    final initialGroup = tagGrouping.getFilterParent(filters.first);
    final filter = await pickTag(
      context: context,
      chipTypes: {ChipType.group},
      initialGroup: initialGroup,
      isValidGroupPick: (destinationGroupUri) {
        return FilterGrouping.isValidParent(destinationGroupUri, childrenUris);
      },
    );
    if (filter == null) return;

    final destinationGroupUri = filter is TagGroupFilter ? filter.uri : null;
    tagGrouping.addToGroup(childrenUris, destinationGroupUri);
    context.read<FilterGroupNotifier>().value = destinationGroupUri;

    final source = context.read<CollectionSource>();
    source.invalidateTagGroupFilterSummary(notify: true);
    browse(context);
  }
}
