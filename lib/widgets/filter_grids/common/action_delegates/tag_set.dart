import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagChipSetActionDelegate extends ChipSetActionDelegate<TagFilter> {
  final Iterable<FilterGridItem<TagFilter>> _items;

  TagChipSetActionDelegate(Iterable<FilterGridItem<TagFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<TagFilter>> get allItems => _items;

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
    required Set<TagFilter> selectedFilters,
  }) {
    final isMain = appMode == AppMode.main;

    switch (action) {
      case ChipSetAction.remove:
        return isMain && isSelecting && !settings.isReadOnly;
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
  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // single/multiple filters
      case ChipSetAction.remove:
        _remove(context);
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  Future<void> _remove(BuildContext context) async {
    final filters = getSelectedFilters(context);

    final source = context.read<CollectionSource>();
    final todoEntries = source.visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet();
    final todoTags = filters.map((v) => v.tag).toSet();

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(l10n.genericDangerWarningDialogMessage),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(l10n.applyButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
    );
    if (confirmed == null || !confirmed) return;

    await EntrySetActionDelegate().removeTags(context, entries: todoEntries, tags: todoTags);

    browse(context);
  }
}
