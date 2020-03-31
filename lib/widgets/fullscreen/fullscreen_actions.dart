import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:tuple/tuple.dart';

enum FullscreenAction { delete, edit, info, open, openMap, print, rename, rotateCCW, rotateCW, setAs, share, toggleFavourite }

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

  static Tuple2<String, IconData> getTextIcon(FullscreenAction action) {
    switch (action) {
      // in app actions
      case FullscreenAction.toggleFavourite:
        // different data depending on toggle state
        return null;
      case FullscreenAction.delete:
        return const Tuple2('Delete', OMIcons.delete);
      case FullscreenAction.info:
        return const Tuple2('Info', OMIcons.info);
      case FullscreenAction.rename:
        return const Tuple2('Rename', OMIcons.title);
      case FullscreenAction.rotateCCW:
        return const Tuple2('Rotate left', OMIcons.rotateLeft);
      case FullscreenAction.rotateCW:
        return const Tuple2('Rotate right', OMIcons.rotateRight);
      case FullscreenAction.print:
        return const Tuple2('Print', OMIcons.print);
      case FullscreenAction.share:
        return const Tuple2('Share', OMIcons.share);
      // external app actions
      case FullscreenAction.edit:
        return const Tuple2('Edit with…', null);
      case FullscreenAction.open:
        return const Tuple2('Open with…', null);
      case FullscreenAction.setAs:
        return const Tuple2('Set as…', null);
      case FullscreenAction.openMap:
        return const Tuple2('Show on map…', null);
    }
    return null;
  }
}
