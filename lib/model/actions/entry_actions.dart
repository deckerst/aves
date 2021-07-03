import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum EntryAction {
  delete,
  export,
  info,
  print,
  rename,
  share,
  toggleFavourite,
  // raster
  rotateCCW,
  rotateCW,
  flip,
  // vector
  viewSource,
  // external
  edit,
  open,
  openMap,
  setAs,
  // platform
  rotateScreen,
  // debug
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
    EntryAction.rotateScreen,
  ];

  static const externalApp = [
    EntryAction.edit,
    EntryAction.open,
    EntryAction.setAs,
    EntryAction.openMap,
  ];

  static const pageActions = [
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
    EntryAction.flip,
  ];
}

extension ExtraEntryAction on EntryAction {
  String getText(BuildContext context) {
    switch (this) {
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return context.l10n.entryActionAddFavourite;
      case EntryAction.delete:
        return context.l10n.entryActionDelete;
      case EntryAction.export:
        return context.l10n.entryActionExport;
      case EntryAction.info:
        return context.l10n.entryActionInfo;
      case EntryAction.rename:
        return context.l10n.entryActionRename;
      case EntryAction.print:
        return context.l10n.entryActionPrint;
      case EntryAction.share:
        return context.l10n.entryActionShare;
      // raster
      case EntryAction.rotateCCW:
        return context.l10n.entryActionRotateCCW;
      case EntryAction.rotateCW:
        return context.l10n.entryActionRotateCW;
      case EntryAction.flip:
        return context.l10n.entryActionFlip;
      // vector
      case EntryAction.viewSource:
        return context.l10n.entryActionViewSource;
      // external
      case EntryAction.edit:
        return context.l10n.entryActionEdit;
      case EntryAction.open:
        return context.l10n.entryActionOpen;
      case EntryAction.setAs:
        return context.l10n.entryActionSetAs;
      case EntryAction.openMap:
        return context.l10n.entryActionOpenMap;
      // platform
      case EntryAction.rotateScreen:
        return context.l10n.entryActionRotateScreen;
      // debug
      case EntryAction.debug:
        return 'Debug';
    }
  }

  IconData? getIcon() {
    switch (this) {
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return AIcons.favourite;
      case EntryAction.delete:
        return AIcons.delete;
      case EntryAction.export:
        return AIcons.export;
      case EntryAction.info:
        return AIcons.info;
      case EntryAction.rename:
        return AIcons.rename;
      case EntryAction.print:
        return AIcons.print;
      case EntryAction.share:
        return AIcons.share;
      // raster
      case EntryAction.rotateCCW:
        return AIcons.rotateLeft;
      case EntryAction.rotateCW:
        return AIcons.rotateRight;
      case EntryAction.flip:
        return AIcons.flip;
      // vector
      case EntryAction.viewSource:
        return AIcons.vector;
      // external
      case EntryAction.edit:
      case EntryAction.open:
      case EntryAction.setAs:
      case EntryAction.openMap:
        return null;
      // platform
      case EntryAction.rotateScreen:
        return AIcons.rotateScreen;
      // debug
      case EntryAction.debug:
        return AIcons.debug;
    }
  }
}
