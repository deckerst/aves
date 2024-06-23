import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraEntrySetActionView on EntrySetAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      // general
      EntrySetAction.configureView => l10n.menuActionConfigureView,
      EntrySetAction.select => l10n.menuActionSelect,
      EntrySetAction.selectAll => l10n.menuActionSelectAll,
      EntrySetAction.selectNone => l10n.menuActionSelectNone,
      // browsing
      EntrySetAction.searchCollection => MaterialLocalizations.of(context).searchFieldLabel,
      EntrySetAction.toggleTitleSearch =>
        // different data depending on toggle state
        l10n.collectionActionShowTitleSearch,
      EntrySetAction.addShortcut => l10n.collectionActionAddShortcut,
      EntrySetAction.setHome => l10n.collectionActionSetHome,
      EntrySetAction.emptyBin => l10n.collectionActionEmptyBin,
      // browsing or selecting
      EntrySetAction.map => l10n.menuActionMap,
      EntrySetAction.slideshow => l10n.menuActionSlideshow,
      EntrySetAction.stats => l10n.menuActionStats,
      EntrySetAction.rescan => l10n.collectionActionRescan,
      // selecting
      EntrySetAction.share => l10n.entryActionShare,
      EntrySetAction.delete => l10n.entryActionDelete,
      EntrySetAction.restore => l10n.entryActionRestore,
      EntrySetAction.copy => l10n.collectionActionCopy,
      EntrySetAction.move => l10n.collectionActionMove,
      EntrySetAction.rename => l10n.entryActionRename,
      EntrySetAction.convert => l10n.entryActionConvert,
      EntrySetAction.toggleFavourite =>
        // different data depending on toggle state
        l10n.entryActionAddFavourite,
      EntrySetAction.rotateCCW => l10n.entryActionRotateCCW,
      EntrySetAction.rotateCW => l10n.entryActionRotateCW,
      EntrySetAction.flip => l10n.entryActionFlip,
      EntrySetAction.editDate => l10n.entryInfoActionEditDate,
      EntrySetAction.editLocation => l10n.entryInfoActionEditLocation,
      EntrySetAction.editTitleDescription => l10n.entryInfoActionEditTitleDescription,
      EntrySetAction.editRating => l10n.entryInfoActionEditRating,
      EntrySetAction.editTags => l10n.entryInfoActionEditTags,
      EntrySetAction.removeMetadata => l10n.entryInfoActionRemoveMetadata,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      // general
      EntrySetAction.configureView => AIcons.view,
      EntrySetAction.select => AIcons.select,
      EntrySetAction.selectAll => AIcons.selected,
      EntrySetAction.selectNone => AIcons.unselected,
      // browsing
      EntrySetAction.searchCollection => AIcons.search,
      EntrySetAction.toggleTitleSearch =>
        // different data depending on toggle state
        AIcons.filter,
      EntrySetAction.addShortcut => AIcons.addShortcut,
      EntrySetAction.setHome => AIcons.home,
      EntrySetAction.emptyBin => AIcons.emptyBin,
      // browsing or selecting
      EntrySetAction.map => AIcons.map,
      EntrySetAction.slideshow => AIcons.slideshow,
      EntrySetAction.stats => AIcons.stats,
      EntrySetAction.rescan => AIcons.refresh,
      // selecting
      EntrySetAction.share => AIcons.share,
      EntrySetAction.delete => AIcons.delete,
      EntrySetAction.restore => AIcons.restore,
      EntrySetAction.copy => AIcons.copy,
      EntrySetAction.move => AIcons.move,
      EntrySetAction.rename => AIcons.name,
      EntrySetAction.convert => AIcons.convert,
      EntrySetAction.toggleFavourite =>
        // different data depending on toggle state
        AIcons.favourite,
      EntrySetAction.rotateCCW => AIcons.rotateLeft,
      EntrySetAction.rotateCW => AIcons.rotateRight,
      EntrySetAction.flip => AIcons.flip,
      EntrySetAction.editDate => AIcons.date,
      EntrySetAction.editLocation => AIcons.location,
      EntrySetAction.editTitleDescription => AIcons.description,
      EntrySetAction.editRating => AIcons.rating,
      EntrySetAction.editTags => AIcons.tag,
      EntrySetAction.removeMetadata => AIcons.clear,
    };
  }
}
