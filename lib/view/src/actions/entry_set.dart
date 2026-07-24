import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraEntrySetActionView on EntrySetAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      // general
      .configureView => l10n.menuActionConfigureView,
      .select => l10n.menuActionSelect,
      .selectAll => l10n.menuActionSelectAll,
      .selectNone => l10n.menuActionSelectNone,
      // browsing
      .searchCollection => MaterialLocalizations.of(context).searchFieldLabel,
      .toggleTitleSearch =>
        // different data depending on toggle state
        l10n.collectionActionShowTitleSearch,
      .addDynamicAlbum => l10n.collectionActionAddDynamicAlbum,
      .addShortcut => l10n.collectionActionAddShortcut,
      .setHome => l10n.collectionActionSetHome,
      .emptyBin => l10n.collectionActionEmptyBin,
      // browsing or selecting
      .map => l10n.menuActionMap,
      .slideshow => l10n.menuActionSlideshow,
      .stats => l10n.menuActionStats,
      .rescan => l10n.collectionActionRescan,
      // selecting
      .share => l10n.entryActionShare,
      .delete => l10n.entryActionDelete,
      .restore => l10n.entryActionRestore,
      .copy => l10n.collectionActionCopy,
      .move => l10n.collectionActionMove,
      .rename => l10n.entryActionRename,
      .convert => l10n.entryActionConvert,
      .copyToClipboard => l10n.entryActionCopyToClipboard,
      .exportGpx => l10n.collectionActionExportGpx,
      .toggleFavourite =>
        // different data depending on toggle state
        l10n.entryActionAddFavourite,
      .rotateCCW => l10n.entryActionRotateCCW,
      .rotateCW => l10n.entryActionRotateCW,
      .flip => l10n.entryActionFlip,
      .editDate => l10n.entryInfoActionEditDate,
      .editLocation => l10n.entryInfoActionEditLocation,
      .editTitleDescription => l10n.entryInfoActionEditTitleDescription,
      .editRating => l10n.entryInfoActionEditRating,
      .editTags => l10n.entryInfoActionEditTags,
      .removeMetadata => l10n.entryInfoActionRemoveMetadata,
      // fab
      .pickCollectionFilters => l10n.pickTooltip,
      .pickMultipleMedia => l10n.pickTooltip,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      // general
      .configureView => AIcons.view,
      .select => AIcons.select,
      .selectAll => AIcons.selected,
      .selectNone => AIcons.unselected,
      // browsing
      .searchCollection => AIcons.search,
      .toggleTitleSearch =>
        // different data depending on toggle state
        AIcons.filter,
      .addDynamicAlbum => AIcons.dynamicAlbum,
      .addShortcut => AIcons.addShortcut,
      .setHome => AIcons.home,
      .emptyBin => AIcons.emptyBin,
      // browsing or selecting
      .map => AIcons.map,
      .slideshow => AIcons.slideshow,
      .stats => AIcons.stats,
      .rescan => AIcons.refresh,
      // selecting
      .share => AIcons.share,
      .delete => AIcons.delete,
      .restore => AIcons.restore,
      .copy => AIcons.copy,
      .move => AIcons.move,
      .rename => AIcons.rename,
      .convert => AIcons.convert,
      .copyToClipboard => AIcons.clipboard,
      .exportGpx => AIcons.route,
      .toggleFavourite =>
        // different data depending on toggle state
        AIcons.favourite,
      .rotateCCW => AIcons.rotateLeft,
      .rotateCW => AIcons.rotateRight,
      .flip => AIcons.flip,
      .editDate => AIcons.date,
      .editLocation => AIcons.location,
      .editTitleDescription => AIcons.description,
      .editRating => AIcons.rating,
      .editTags => AIcons.tag,
      .removeMetadata => AIcons.clear,
      // fab
      .pickCollectionFilters => AIcons.apply,
      .pickMultipleMedia => AIcons.apply,
    };
  }
}
