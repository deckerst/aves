import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum EntryAction {
  delete,
  edit,
  export,
  flip,
  info,
  open,
  openMap,
  print,
  rename,
  rotateCCW,
  rotateCW,
  setAs,
  share,
  toggleFavourite,
  viewSource,
  debug,
}

class EntryActions {
  static const selection = [
    EntryAction.share,
    EntryAction.delete,
  ];

  static const inApp = [
    EntryAction.info,
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.delete,
    EntryAction.rename,
    EntryAction.export,
    EntryAction.print,
    EntryAction.viewSource,
  ];

  static const externalApp = [
    EntryAction.edit,
    EntryAction.open,
    EntryAction.setAs,
    EntryAction.openMap,
  ];
}

extension ExtraEntryAction on EntryAction {
  String getText(BuildContext context) {
    switch (this) {
      // in app actions
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case EntryAction.delete:
        return context.l10n.entryActionDelete;
      case EntryAction.export:
        return context.l10n.entryActionExport;
      case EntryAction.info:
        return context.l10n.entryActionInfo;
      case EntryAction.rename:
        return context.l10n.entryActionRename;
      case EntryAction.rotateCCW:
        return context.l10n.entryActionRotateCCW;
      case EntryAction.rotateCW:
        return context.l10n.entryActionRotateCW;
      case EntryAction.flip:
        return context.l10n.entryActionFlip;
      case EntryAction.print:
        return context.l10n.entryActionPrint;
      case EntryAction.share:
        return context.l10n.entryActionShare;
      case EntryAction.viewSource:
        return context.l10n.entryActionViewSource;
      // external app actions
      case EntryAction.edit:
        return context.l10n.entryActionEdit;
      case EntryAction.open:
        return context.l10n.entryActionOpen;
      case EntryAction.setAs:
        return context.l10n.entryActionSetAs;
      case EntryAction.openMap:
        return context.l10n.entryActionOpenMap;
      case EntryAction.debug:
        return 'Debug';
    }
    return null;
  }

  IconData getIcon() {
    switch (this) {
      // in app actions
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case EntryAction.delete:
        return AIcons.delete;
      case EntryAction.export:
        return AIcons.export;
      case EntryAction.info:
        return AIcons.info;
      case EntryAction.rename:
        return AIcons.rename;
      case EntryAction.rotateCCW:
        return AIcons.rotateLeft;
      case EntryAction.rotateCW:
        return AIcons.rotateRight;
      case EntryAction.flip:
        return AIcons.flip;
      case EntryAction.print:
        return AIcons.print;
      case EntryAction.share:
        return AIcons.share;
      case EntryAction.viewSource:
        return AIcons.vector;
      // external app actions
      case EntryAction.edit:
      case EntryAction.open:
      case EntryAction.setAs:
      case EntryAction.openMap:
        return null;
      case EntryAction.debug:
        return AIcons.debug;
    }
    return null;
  }
}
