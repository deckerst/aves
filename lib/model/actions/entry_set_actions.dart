import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

enum EntrySetAction {
  // general
  configureView,
  select,
  selectAll,
  selectNone,
  // browsing
  searchCollection,
  toggleTitleSearch,
  addShortcut,
  emptyBin,
  // browsing or selecting
  map,
  stats,
  rescan,
  // selecting
  share,
  delete,
  restore,
  copy,
  move,
  rename,
  toggleFavourite,
  rotateCCW,
  rotateCW,
  flip,
  editDate,
  editLocation,
  editRating,
  editTags,
  removeMetadata,
}

class EntrySetActions {
  static const general = [
    EntrySetAction.configureView,
    EntrySetAction.select,
    EntrySetAction.selectAll,
    EntrySetAction.selectNone,
  ];

  static const pageBrowsing = [
    EntrySetAction.searchCollection,
    EntrySetAction.toggleTitleSearch,
    EntrySetAction.addShortcut,
    EntrySetAction.map,
    EntrySetAction.stats,
    EntrySetAction.rescan,
    EntrySetAction.emptyBin,
  ];

  // exclude bin related actions
  static const collectionEditorBrowsing = [
    EntrySetAction.searchCollection,
    EntrySetAction.toggleTitleSearch,
    EntrySetAction.addShortcut,
    EntrySetAction.map,
    EntrySetAction.stats,
    EntrySetAction.rescan,
  ];

  static const pageSelection = [
    EntrySetAction.share,
    EntrySetAction.delete,
    EntrySetAction.restore,
    EntrySetAction.copy,
    EntrySetAction.move,
    EntrySetAction.rename,
    EntrySetAction.toggleFavourite,
    EntrySetAction.map,
    EntrySetAction.stats,
    EntrySetAction.rescan,
    // editing actions are in their subsection
  ];

  // exclude bin related actions
  static const collectionEditorSelection = [
    EntrySetAction.share,
    EntrySetAction.delete,
    EntrySetAction.copy,
    EntrySetAction.move,
    EntrySetAction.rename,
    EntrySetAction.toggleFavourite,
    EntrySetAction.map,
    EntrySetAction.stats,
    EntrySetAction.rescan,
    // editing actions are in their subsection
  ];

  static const edit = [
    EntrySetAction.editDate,
    EntrySetAction.editLocation,
    EntrySetAction.editRating,
    EntrySetAction.editTags,
    EntrySetAction.removeMetadata,
  ];
}

extension ExtraEntrySetAction on EntrySetAction {
  String getText(BuildContext context) {
    switch (this) {
      // general
      case EntrySetAction.configureView:
        return context.l10n.menuActionConfigureView;
      case EntrySetAction.select:
        return context.l10n.menuActionSelect;
      case EntrySetAction.selectAll:
        return context.l10n.menuActionSelectAll;
      case EntrySetAction.selectNone:
        return context.l10n.menuActionSelectNone;
      // browsing
      case EntrySetAction.searchCollection:
        return MaterialLocalizations.of(context).searchFieldLabel;
      case EntrySetAction.toggleTitleSearch:
        // different data depending on toggle state
        return context.l10n.collectionActionShowTitleSearch;
      case EntrySetAction.addShortcut:
        return context.l10n.collectionActionAddShortcut;
      case EntrySetAction.emptyBin:
        return context.l10n.collectionActionEmptyBin;
      // browsing or selecting
      case EntrySetAction.map:
        return context.l10n.menuActionMap;
      case EntrySetAction.stats:
        return context.l10n.menuActionStats;
      case EntrySetAction.rescan:
        return context.l10n.collectionActionRescan;
      // selecting
      case EntrySetAction.share:
        return context.l10n.entryActionShare;
      case EntrySetAction.delete:
        return context.l10n.entryActionDelete;
      case EntrySetAction.restore:
        return context.l10n.entryActionRestore;
      case EntrySetAction.copy:
        return context.l10n.collectionActionCopy;
      case EntrySetAction.move:
        return context.l10n.collectionActionMove;
      case EntrySetAction.rename:
        return context.l10n.entryActionRename;
      case EntrySetAction.toggleFavourite:
        // different data depending on toggle state
        return context.l10n.entryActionAddFavourite;
      case EntrySetAction.rotateCCW:
        return context.l10n.entryActionRotateCCW;
      case EntrySetAction.rotateCW:
        return context.l10n.entryActionRotateCW;
      case EntrySetAction.flip:
        return context.l10n.entryActionFlip;
      case EntrySetAction.editDate:
        return context.l10n.entryInfoActionEditDate;
      case EntrySetAction.editLocation:
        return context.l10n.entryInfoActionEditLocation;
      case EntrySetAction.editRating:
        return context.l10n.entryInfoActionEditRating;
      case EntrySetAction.editTags:
        return context.l10n.entryInfoActionEditTags;
      case EntrySetAction.removeMetadata:
        return context.l10n.entryInfoActionRemoveMetadata;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      // general
      case EntrySetAction.configureView:
        return AIcons.view;
      case EntrySetAction.select:
        return AIcons.select;
      case EntrySetAction.selectAll:
        return AIcons.selected;
      case EntrySetAction.selectNone:
        return AIcons.unselected;
      // browsing
      case EntrySetAction.searchCollection:
        return AIcons.search;
      case EntrySetAction.toggleTitleSearch:
        // different data depending on toggle state
        return AIcons.filter;
      case EntrySetAction.addShortcut:
        return AIcons.addShortcut;
      case EntrySetAction.emptyBin:
        return AIcons.emptyBin;
      // browsing or selecting
      case EntrySetAction.map:
        return AIcons.map;
      case EntrySetAction.stats:
        return AIcons.stats;
      case EntrySetAction.rescan:
        return AIcons.refresh;
      // selecting
      case EntrySetAction.share:
        return AIcons.share;
      case EntrySetAction.delete:
        return AIcons.delete;
      case EntrySetAction.restore:
        return AIcons.restore;
      case EntrySetAction.copy:
        return AIcons.copy;
      case EntrySetAction.move:
        return AIcons.move;
      case EntrySetAction.rename:
        return AIcons.name;
      case EntrySetAction.toggleFavourite:
        // different data depending on toggle state
        return AIcons.favourite;
      case EntrySetAction.rotateCCW:
        return AIcons.rotateLeft;
      case EntrySetAction.rotateCW:
        return AIcons.rotateRight;
      case EntrySetAction.flip:
        return AIcons.flip;
      case EntrySetAction.editDate:
        return AIcons.date;
      case EntrySetAction.editLocation:
        return AIcons.location;
      case EntrySetAction.editRating:
        return AIcons.editRating;
      case EntrySetAction.editTags:
        return AIcons.editTags;
      case EntrySetAction.removeMetadata:
        return AIcons.clear;
    }
  }
}
