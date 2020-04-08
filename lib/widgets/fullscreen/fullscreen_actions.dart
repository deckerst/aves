import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

enum FullscreenAction { delete, edit, info, open, openMap, print, rename, rotateCCW, rotateCW, setAs, share, toggleFavourite, debug }

class FullscreenActions {
  static const inApp = [
    FullscreenAction.info,
    FullscreenAction.toggleFavourite,
    FullscreenAction.share,
    FullscreenAction.delete,
    FullscreenAction.rename,
    FullscreenAction.rotateCCW,
    FullscreenAction.rotateCW,
    FullscreenAction.print,
  ];

  static const externalApp = [
    FullscreenAction.edit,
    FullscreenAction.open,
    FullscreenAction.setAs,
    FullscreenAction.openMap,
  ];
}

extension ExtraFullscreenAction on FullscreenAction {
  String getText() {
    switch (this) {
      // in app actions
      case FullscreenAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case FullscreenAction.delete:
        return 'Delete';
      case FullscreenAction.info:
        return 'Info';
      case FullscreenAction.rename:
        return 'Rename';
      case FullscreenAction.rotateCCW:
        return 'Rotate left';
      case FullscreenAction.rotateCW:
        return 'Rotate right';
      case FullscreenAction.print:
        return 'Print';
      case FullscreenAction.share:
        return 'Share';
      // external app actions
      case FullscreenAction.edit:
        return 'Edit with…';
      case FullscreenAction.open:
        return 'Open with…';
      case FullscreenAction.setAs:
        return 'Set as…';
      case FullscreenAction.openMap:
        return 'Show on map…';
      case FullscreenAction.debug:
        return 'Debug';
    }
    return null;
  }

  IconData getIcon() {
    switch (this) {
      // in app actions
      case FullscreenAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case FullscreenAction.delete:
        return OMIcons.delete;
      case FullscreenAction.info:
        return OMIcons.info;
      case FullscreenAction.rename:
        return OMIcons.title;
      case FullscreenAction.rotateCCW:
        return OMIcons.rotateLeft;
      case FullscreenAction.rotateCW:
        return OMIcons.rotateRight;
      case FullscreenAction.print:
        return OMIcons.print;
      case FullscreenAction.share:
        return OMIcons.share;
      // external app actions
      case FullscreenAction.edit:
      case FullscreenAction.open:
      case FullscreenAction.setAs:
      case FullscreenAction.openMap:
        return null;
      case FullscreenAction.debug:
        return OMIcons.whatshot;
    }
    return null;
  }
}
