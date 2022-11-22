import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum EntryAction {
  info,
  addShortcut,
  copyToClipboard,
  delete,
  restore,
  convert,
  print,
  rename,
  copy,
  move,
  share,
  toggleFavourite,
  // raster
  rotateCCW,
  rotateCW,
  flip,
  // vector
  viewSource,
  // video
  videoCaptureFrame,
  videoSelectStreams,
  videoSetSpeed,
  videoToggleMute,
  videoSettings,
  videoTogglePlay,
  videoReplay10,
  videoSkip10,
  // external
  edit,
  open,
  openMap,
  setAs,
  // platform
  rotateScreen,
  // metadata
  editDate,
  editLocation,
  editTitleDescription,
  editRating,
  editTags,
  removeMetadata,
  exportMetadata,
  // metadata / GeoTIFF
  showGeoTiffOnMap,
  // metadata / motion photo
  convertMotionPhotoToStillImage,
  viewMotionPhotoVideo,
  // debug
  debug,
}

class EntryActions {
  static const topLevel = [
    EntryAction.info,
    EntryAction.share,
    EntryAction.edit,
    EntryAction.rename,
    EntryAction.delete,
    EntryAction.copy,
    EntryAction.move,
    EntryAction.toggleFavourite,
    EntryAction.rotateScreen,
    EntryAction.viewSource,
  ];

  static const export = [
    EntryAction.convert,
    EntryAction.addShortcut,
    EntryAction.copyToClipboard,
    EntryAction.print,
    EntryAction.open,
    EntryAction.openMap,
    EntryAction.setAs,
  ];

  static const exportExternal = [
    EntryAction.open,
    EntryAction.openMap,
    EntryAction.setAs,
  ];

  static const pageActions = [
    EntryAction.videoCaptureFrame,
    EntryAction.videoSelectStreams,
    EntryAction.videoSetSpeed,
    EntryAction.videoToggleMute,
    EntryAction.videoSettings,
    EntryAction.videoTogglePlay,
    EntryAction.videoReplay10,
    EntryAction.videoSkip10,
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
    EntryAction.flip,
  ];

  static const trashed = [
    EntryAction.delete,
    EntryAction.restore,
    EntryAction.debug,
  ];

  static const video = [
    EntryAction.videoCaptureFrame,
    EntryAction.videoToggleMute,
    EntryAction.videoSetSpeed,
    EntryAction.videoSelectStreams,
    EntryAction.videoSettings,
  ];

  static const commonMetadataActions = [
    EntryAction.editDate,
    EntryAction.editLocation,
    EntryAction.editTitleDescription,
    EntryAction.editRating,
    EntryAction.editTags,
    EntryAction.removeMetadata,
    EntryAction.exportMetadata,
  ];

  static const formatSpecificMetadataActions = [
    EntryAction.showGeoTiffOnMap,
    EntryAction.convertMotionPhotoToStillImage,
    EntryAction.viewMotionPhotoVideo,
  ];
}

extension ExtraEntryAction on EntryAction {
  String getText(BuildContext context) {
    switch (this) {
      case EntryAction.info:
        return context.l10n.entryActionInfo;
      case EntryAction.addShortcut:
        return context.l10n.collectionActionAddShortcut;
      case EntryAction.copyToClipboard:
        return context.l10n.entryActionCopyToClipboard;
      case EntryAction.delete:
        return context.l10n.entryActionDelete;
      case EntryAction.restore:
        return context.l10n.entryActionRestore;
      case EntryAction.convert:
        return context.l10n.entryActionConvert;
      case EntryAction.print:
        return context.l10n.entryActionPrint;
      case EntryAction.rename:
        return context.l10n.entryActionRename;
      case EntryAction.copy:
        return context.l10n.collectionActionCopy;
      case EntryAction.move:
        return context.l10n.collectionActionMove;
      case EntryAction.share:
        return context.l10n.entryActionShare;
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return context.l10n.entryActionAddFavourite;
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
      // video
      case EntryAction.videoCaptureFrame:
        return context.l10n.videoActionCaptureFrame;
      case EntryAction.videoToggleMute:
        // different data depending on toggle state
        return context.l10n.videoActionMute;
      case EntryAction.videoSelectStreams:
        return context.l10n.videoActionSelectStreams;
      case EntryAction.videoSetSpeed:
        return context.l10n.videoActionSetSpeed;
      case EntryAction.videoSettings:
        return context.l10n.videoActionSettings;
      case EntryAction.videoTogglePlay:
        // different data depending on toggle state
        return context.l10n.videoActionPlay;
      case EntryAction.videoReplay10:
        return context.l10n.videoActionReplay10;
      case EntryAction.videoSkip10:
        return context.l10n.videoActionSkip10;
      // external
      case EntryAction.edit:
        return context.l10n.entryActionEdit;
      case EntryAction.open:
        return context.l10n.entryActionOpen;
      case EntryAction.openMap:
        return context.l10n.entryActionOpenMap;
      case EntryAction.setAs:
        return context.l10n.entryActionSetAs;
      // platform
      case EntryAction.rotateScreen:
        return context.l10n.entryActionRotateScreen;
      // metadata
      case EntryAction.editDate:
        return context.l10n.entryInfoActionEditDate;
      case EntryAction.editLocation:
        return context.l10n.entryInfoActionEditLocation;
      case EntryAction.editTitleDescription:
        return context.l10n.entryInfoActionEditTitleDescription;
      case EntryAction.editRating:
        return context.l10n.entryInfoActionEditRating;
      case EntryAction.editTags:
        return context.l10n.entryInfoActionEditTags;
      case EntryAction.removeMetadata:
        return context.l10n.entryInfoActionRemoveMetadata;
      case EntryAction.exportMetadata:
        return context.l10n.entryInfoActionExportMetadata;
      // metadata / GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        return context.l10n.entryActionShowGeoTiffOnMap;
      // metadata / motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        return context.l10n.entryActionConvertMotionPhotoToStillImage;
      case EntryAction.viewMotionPhotoVideo:
        return context.l10n.entryActionViewMotionPhotoVideo;
      // debug
      case EntryAction.debug:
        return 'Debug';
    }
  }

  Widget getIcon() {
    final child = Icon(getIconData());
    switch (this) {
      case EntryAction.debug:
        return ShaderMask(
          shaderCallback: AvesColorsData.debugGradient.createShader,
          blendMode: BlendMode.srcIn,
          child: child,
        );
      default:
        return child;
    }
  }

  IconData getIconData() {
    switch (this) {
      case EntryAction.info:
        return AIcons.info;
      case EntryAction.addShortcut:
        return AIcons.addShortcut;
      case EntryAction.copyToClipboard:
        return AIcons.clipboard;
      case EntryAction.delete:
        return AIcons.delete;
      case EntryAction.restore:
        return AIcons.restore;
      case EntryAction.convert:
        return AIcons.convert;
      case EntryAction.print:
        return AIcons.print;
      case EntryAction.rename:
        return AIcons.name;
      case EntryAction.copy:
        return AIcons.copy;
      case EntryAction.move:
        return AIcons.move;
      case EntryAction.share:
        return AIcons.share;
      case EntryAction.toggleFavourite:
        // different data depending on toggle state
        return AIcons.favourite;
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
      // video
      case EntryAction.videoCaptureFrame:
        return AIcons.captureFrame;
      case EntryAction.videoToggleMute:
        // different data depending on toggle state
        return AIcons.mute;
      case EntryAction.videoSelectStreams:
        return AIcons.streams;
      case EntryAction.videoSetSpeed:
        return AIcons.speed;
      case EntryAction.videoSettings:
        return AIcons.videoSettings;
      case EntryAction.videoTogglePlay:
        // different data depending on toggle state
        return AIcons.play;
      case EntryAction.videoReplay10:
        return AIcons.replay10;
      case EntryAction.videoSkip10:
        return AIcons.skip10;
      // external
      case EntryAction.edit:
        return AIcons.edit;
      case EntryAction.open:
        return AIcons.openOutside;
      case EntryAction.openMap:
        return AIcons.map;
      case EntryAction.setAs:
        return AIcons.setAs;
      // platform
      case EntryAction.rotateScreen:
        return AIcons.rotateScreen;
      // metadata
      case EntryAction.editDate:
        return AIcons.date;
      case EntryAction.editLocation:
        return AIcons.location;
      case EntryAction.editTitleDescription:
        return AIcons.description;
      case EntryAction.editRating:
        return AIcons.editRating;
      case EntryAction.editTags:
        return AIcons.editTags;
      case EntryAction.removeMetadata:
        return AIcons.clear;
      case EntryAction.exportMetadata:
        return AIcons.fileExport;
      // metadata / GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        return AIcons.map;
      // metadata / motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        return AIcons.convertToStillImage;
      case EntryAction.viewMotionPhotoVideo:
        return AIcons.openVideo;
      // debug
      case EntryAction.debug:
        return AIcons.debug;
    }
  }
}
