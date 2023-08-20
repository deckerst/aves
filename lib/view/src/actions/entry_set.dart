import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

extension ExtraEntrySetActionView on EntrySetAction {
  String getText(BuildContext context) {
    return switch (this) {
      // general
      EntrySetAction.configureView => context.l10n.menuActionConfigureView,
      EntrySetAction.select => context.l10n.menuActionSelect,
      EntrySetAction.selectAll => context.l10n.menuActionSelectAll,
      EntrySetAction.selectNone => context.l10n.menuActionSelectNone,
      // browsing
      EntrySetAction.searchCollection => MaterialLocalizations.of(context).searchFieldLabel,
      EntrySetAction.toggleTitleSearch =>
        // different data depending on toggle state
        context.l10n.collectionActionShowTitleSearch,
      EntrySetAction.addShortcut => context.l10n.collectionActionAddShortcut,
      EntrySetAction.emptyBin => context.l10n.collectionActionEmptyBin,
      // browsing or selecting
      EntrySetAction.map => context.l10n.menuActionMap,
      EntrySetAction.slideshow => context.l10n.menuActionSlideshow,
      EntrySetAction.stats => context.l10n.menuActionStats,
      EntrySetAction.rescan => context.l10n.collectionActionRescan,
      // selecting
      EntrySetAction.share => context.l10n.entryActionShare,
      EntrySetAction.delete => context.l10n.entryActionDelete,
      EntrySetAction.restore => context.l10n.entryActionRestore,
      EntrySetAction.copy => context.l10n.collectionActionCopy,
      EntrySetAction.move => context.l10n.collectionActionMove,
      EntrySetAction.rename => context.l10n.entryActionRename,
      EntrySetAction.convert => context.l10n.entryActionConvert,
      EntrySetAction.toggleFavourite =>
        // different data depending on toggle state
        context.l10n.entryActionAddFavourite,
      EntrySetAction.rotateCCW => context.l10n.entryActionRotateCCW,
      EntrySetAction.rotateCW => context.l10n.entryActionRotateCW,
      EntrySetAction.flip => context.l10n.entryActionFlip,
      EntrySetAction.editDate => context.l10n.entryInfoActionEditDate,
      EntrySetAction.editLocation => context.l10n.entryInfoActionEditLocation,
      EntrySetAction.editTitleDescription => context.l10n.entryInfoActionEditTitleDescription,
      EntrySetAction.editRating => context.l10n.entryInfoActionEditRating,
      EntrySetAction.editTags => context.l10n.entryInfoActionEditTags,
      EntrySetAction.removeMetadata => context.l10n.entryInfoActionRemoveMetadata,
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
