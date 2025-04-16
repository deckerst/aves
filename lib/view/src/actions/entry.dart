import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryActionView on EntryAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntryAction.info => l10n.entryActionInfo,
      EntryAction.addShortcut => l10n.collectionActionAddShortcut,
      EntryAction.copyToClipboard => l10n.entryActionCopyToClipboard,
      EntryAction.delete => l10n.entryActionDelete,
      EntryAction.restore => l10n.entryActionRestore,
      EntryAction.convert => l10n.entryActionConvert,
      EntryAction.print => l10n.entryActionPrint,
      EntryAction.rename => l10n.entryActionRename,
      EntryAction.copy => l10n.collectionActionCopy,
      EntryAction.move => l10n.collectionActionMove,
      EntryAction.share => l10n.entryActionShare,
      EntryAction.toggleFavourite =>
        // different data depending on toggle state
        l10n.entryActionAddFavourite,
      // raster
      EntryAction.rotateCCW => l10n.entryActionRotateCCW,
      EntryAction.rotateCW => l10n.entryActionRotateCW,
      EntryAction.flip => l10n.entryActionFlip,
      // vector
      EntryAction.viewSource => l10n.entryActionViewSource,
      // video
      EntryAction.lockViewer => l10n.viewerActionLock,
      EntryAction.videoCaptureFrame => l10n.videoActionCaptureFrame,
      EntryAction.videoToggleMute =>
        // different data depending on toggle state
        l10n.videoActionMute,
      EntryAction.videoSelectStreams => l10n.videoActionSelectStreams,
      EntryAction.videoSetSpeed => l10n.videoActionSetSpeed,
      EntryAction.videoABRepeat => l10n.videoActionABRepeat,
      EntryAction.videoSettings => l10n.viewerActionSettings,
      EntryAction.videoTogglePlay =>
        // different data depending on toggle state
        l10n.videoActionPlay,
      EntryAction.videoReplay10 => l10n.videoActionReplay10,
      EntryAction.videoSkip10 => l10n.videoActionSkip10,
      EntryAction.videoShowPreviousFrame => l10n.videoActionShowPreviousFrame,
      EntryAction.videoShowNextFrame => l10n.videoActionShowNextFrame,
      // external
      EntryAction.edit => l10n.entryActionEdit,
      EntryAction.open => l10n.entryActionOpen,
      EntryAction.openVideoPlayer => l10n.videoControlsPlayOutside,
      EntryAction.openMap => l10n.entryActionOpenMap,
      EntryAction.setAs => l10n.entryActionSetAs,
      EntryAction.cast => l10n.entryActionCast,
      // platform
      EntryAction.rotateScreen => l10n.entryActionRotateScreen,
      // metadata
      EntryAction.editDate => l10n.entryInfoActionEditDate,
      EntryAction.editLocation => l10n.entryInfoActionEditLocation,
      EntryAction.editTitleDescription => l10n.entryInfoActionEditTitleDescription,
      EntryAction.editRating => l10n.entryInfoActionEditRating,
      EntryAction.editTags => l10n.entryInfoActionEditTags,
      EntryAction.removeMetadata => l10n.entryInfoActionRemoveMetadata,
      EntryAction.exportMetadata => l10n.entryInfoActionExportMetadata,
      // metadata / GeoTIFF
      EntryAction.showGeoTiffOnMap => l10n.entryActionShowGeoTiffOnMap,
      // metadata / motion photo
      EntryAction.convertMotionPhotoToStillImage => l10n.entryActionConvertMotionPhotoToStillImage,
      EntryAction.viewMotionPhotoVideo => l10n.entryActionViewMotionPhotoVideo,
      // debug
      EntryAction.debug => 'Debug',
    };
  }

  Widget getIcon() {
    final child = Icon(getIconData());
    return switch (this) {
      EntryAction.debug => ShaderMask(
          shaderCallback: AvesColorsData.debugGradient.createShader,
          blendMode: BlendMode.srcIn,
          child: child,
        ),
      _ => child,
    };
  }

  IconData getIconData() {
    return switch (this) {
      EntryAction.info => AIcons.info,
      EntryAction.addShortcut => AIcons.addShortcut,
      EntryAction.copyToClipboard => AIcons.clipboard,
      EntryAction.delete => AIcons.delete,
      EntryAction.restore => AIcons.restore,
      EntryAction.convert => AIcons.convert,
      EntryAction.print => AIcons.print,
      EntryAction.rename => AIcons.rename,
      EntryAction.copy => AIcons.copy,
      EntryAction.move => AIcons.move,
      EntryAction.share => AIcons.share,
      EntryAction.toggleFavourite =>
        // different data depending on toggle state
        AIcons.favourite,
      // raster
      EntryAction.rotateCCW => AIcons.rotateLeft,
      EntryAction.rotateCW => AIcons.rotateRight,
      EntryAction.flip => AIcons.flip,
      // vector
      EntryAction.viewSource => AIcons.vector,
      // video
      EntryAction.lockViewer => AIcons.viewerLock,
      EntryAction.videoCaptureFrame => AIcons.captureFrame,
      EntryAction.videoToggleMute =>
        // different data depending on toggle state
        AIcons.mute,
      EntryAction.videoSelectStreams => AIcons.selectStreams,
      EntryAction.videoSetSpeed => AIcons.setSpeed,
      EntryAction.videoABRepeat => AIcons.repeat,
      EntryAction.videoSettings => AIcons.videoSettings,
      EntryAction.videoTogglePlay =>
        // different data depending on toggle state
        AIcons.play,
      EntryAction.videoReplay10 => AIcons.replay10,
      EntryAction.videoSkip10 => AIcons.skip10,
      EntryAction.videoShowPreviousFrame => AIcons.previousFrame,
      EntryAction.videoShowNextFrame => AIcons.nextFrame,
      // external
      EntryAction.edit => AIcons.edit,
      EntryAction.open => AIcons.openOutside,
      EntryAction.openVideoPlayer => AIcons.openOutside,
      EntryAction.openMap => AIcons.map,
      EntryAction.setAs => AIcons.setAs,
      EntryAction.cast => AIcons.cast,
      // platform
      EntryAction.rotateScreen => AIcons.rotateScreen,
      // metadata
      EntryAction.editDate => AIcons.date,
      EntryAction.editLocation => AIcons.location,
      EntryAction.editTitleDescription => AIcons.description,
      EntryAction.editRating => AIcons.rating,
      EntryAction.editTags => AIcons.tag,
      EntryAction.removeMetadata => AIcons.clear,
      EntryAction.exportMetadata => AIcons.fileExport,
      // metadata / GeoTIFF
      EntryAction.showGeoTiffOnMap => AIcons.map,
      // metadata / motion photo
      EntryAction.convertMotionPhotoToStillImage => AIcons.convertToStillImage,
      EntryAction.viewMotionPhotoVideo => AIcons.openVideoPart,
      // debug
      EntryAction.debug => AIcons.debug,
    };
  }
}
