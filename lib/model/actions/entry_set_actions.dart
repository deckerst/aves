import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum EntrySetAction {
  // general
  sort,
  group,
  select,
  selectAll,
  selectNone,
  // all
  addShortcut,
  // all or entry selection
  map,
  stats,
  // entry selection
  share,
  delete,
  copy,
  move,
  rescan,
  editDate,
}

class EntrySetActions {
  static const selection = [
    EntrySetAction.share,
    EntrySetAction.delete,
    EntrySetAction.copy,
    EntrySetAction.move,
    EntrySetAction.rescan,
    EntrySetAction.map,
    EntrySetAction.stats,
  ];
}

extension ExtraEntrySetAction on EntrySetAction {
  String getText(BuildContext context) {
    switch (this) {
      // general
      case EntrySetAction.sort:
        return context.l10n.menuActionSort;
      case EntrySetAction.group:
        return context.l10n.menuActionGroup;
      case EntrySetAction.select:
        return context.l10n.menuActionSelect;
      case EntrySetAction.selectAll:
        return context.l10n.menuActionSelectAll;
      case EntrySetAction.selectNone:
        return context.l10n.menuActionSelectNone;
      // all
      case EntrySetAction.addShortcut:
        return context.l10n.collectionActionAddShortcut;
      // all or entry selection
      case EntrySetAction.map:
        return context.l10n.menuActionMap;
      case EntrySetAction.stats:
        return context.l10n.menuActionStats;
      // entry selection
      case EntrySetAction.share:
        return context.l10n.entryActionShare;
      case EntrySetAction.delete:
        return context.l10n.entryActionDelete;
      case EntrySetAction.copy:
        return context.l10n.collectionActionCopy;
      case EntrySetAction.move:
        return context.l10n.collectionActionMove;
      case EntrySetAction.rescan:
        return context.l10n.collectionActionRescan;
      case EntrySetAction.editDate:
        return context.l10n.entryInfoActionEditDate;
    }
  }

  Widget getIcon() {
    return Icon(_getIconData());
  }

  IconData _getIconData() {
    switch (this) {
      // general
      case EntrySetAction.sort:
        return AIcons.sort;
      case EntrySetAction.group:
        return AIcons.group;
      case EntrySetAction.select:
        return AIcons.select;
      case EntrySetAction.selectAll:
        return AIcons.selected;
      case EntrySetAction.selectNone:
        return AIcons.unselected;
      // all
      case EntrySetAction.addShortcut:
        return AIcons.addShortcut;
      // all or entry selection
      case EntrySetAction.map:
        return AIcons.map;
      case EntrySetAction.stats:
        return AIcons.stats;
      // entry selection
      case EntrySetAction.share:
        return AIcons.share;
      case EntrySetAction.delete:
        return AIcons.delete;
      case EntrySetAction.copy:
        return AIcons.copy;
      case EntrySetAction.move:
        return AIcons.move;
      case EntrySetAction.rescan:
        return AIcons.refresh;
      case EntrySetAction.editDate:
        return AIcons.date;
    }
  }
}
