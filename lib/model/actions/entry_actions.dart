import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
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
  // motion photo,
  viewMotionPhotoVideo,
  // external
  copyToClipboard,
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
    EntryAction.copyToClipboard,
    EntryAction.print,
    EntryAction.viewSource,
    EntryAction.viewMotionPhotoVideo,
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
      case EntryAction.copyToClipboard:
        return context.l10n.entryActionCopyToClipboard;
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
      // motion photo
      case EntryAction.viewMotionPhotoVideo:
        return context.l10n.entryActionViewMotionPhotoVideo;
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

  Widget? getIcon() {
    final icon = getIconData();
    if (icon == null) return null;

    final child = Icon(icon);
    switch (this) {
      case EntryAction.debug:
        return ShaderMask(
          shaderCallback: Themes.debugGradient.createShader,
          child: child,
        );
      default:
        return child;
    }
  }

  IconData? getIconData() {
    switch (this) {
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return AIcons.favourite;
      case EntryAction.copyToClipboard:
        return AIcons.clipboard;
      case EntryAction.delete:
        return AIcons.delete;
      case EntryAction.export:
        return AIcons.saveAs;
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
      // motion photo
      case EntryAction.viewMotionPhotoVideo:
        return AIcons.motionPhoto;
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
