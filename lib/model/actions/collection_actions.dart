import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum CollectionAction {
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
  copy,
  move,
  refreshMetadata,
}

extension ExtraCollectionAction on CollectionAction {
  String getText(BuildContext context) {
    switch (this) {
      // general
      case CollectionAction.sort:
        return context.l10n.menuActionSort;
      case CollectionAction.group:
        return context.l10n.menuActionGroup;
      case CollectionAction.select:
        return context.l10n.menuActionSelect;
      case CollectionAction.selectAll:
        return context.l10n.menuActionSelectAll;
      case CollectionAction.selectNone:
        return context.l10n.menuActionSelectNone;
      // all
      case CollectionAction.addShortcut:
        return context.l10n.collectionActionAddShortcut;
      // all or entry selection
      case CollectionAction.map:
        return context.l10n.menuActionMap;
      case CollectionAction.stats:
        return context.l10n.menuActionStats;
      // entry selection
      case CollectionAction.copy:
        return context.l10n.collectionActionCopy;
      case CollectionAction.move:
        return context.l10n.collectionActionMove;
      case CollectionAction.refreshMetadata:
        return context.l10n.collectionActionRefreshMetadata;
    }
  }

  IconData? getIcon() {
    switch (this) {
      // general
      case CollectionAction.sort:
        return AIcons.sort;
      case CollectionAction.group:
        return AIcons.group;
      case CollectionAction.select:
        return AIcons.select;
      case CollectionAction.selectAll:
        return AIcons.selected;
      case CollectionAction.selectNone:
        return AIcons.unselected;
      // all
      case CollectionAction.addShortcut:
        return AIcons.addShortcut;
      // all or entry selection
      case CollectionAction.map:
        return AIcons.map;
      case CollectionAction.stats:
        return AIcons.stats;
      // entry selection
      case CollectionAction.copy:
        return AIcons.copy;
      case CollectionAction.move:
        return AIcons.move;
      case CollectionAction.refreshMetadata:
        return AIcons.refresh;
    }
  }
}
