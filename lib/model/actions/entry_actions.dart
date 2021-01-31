import 'package:aves/theme/icons.dart';
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
  String getText() {
    switch (this) {
      // in app actions
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case EntryAction.delete:
        return 'Delete';
      case EntryAction.export:
        return 'Export';
      case EntryAction.info:
        return 'Info';
      case EntryAction.rename:
        return 'Rename';
      case EntryAction.rotateCCW:
        return 'Rotate counterclockwise';
      case EntryAction.rotateCW:
        return 'Rotate clockwise';
      case EntryAction.flip:
        return 'Flip horizontally';
      case EntryAction.print:
        return 'Print';
      case EntryAction.share:
        return 'Share';
      case EntryAction.viewSource:
        return 'View source';
      // external app actions
      case EntryAction.edit:
        return 'Edit with…';
      case EntryAction.open:
        return 'Open with…';
      case EntryAction.setAs:
        return 'Set as…';
      case EntryAction.openMap:
        return 'Show on map…';
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
