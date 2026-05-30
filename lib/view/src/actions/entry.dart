import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryActionView on EntryAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .info => l10n.entryActionInfo,
      .addShortcut => l10n.collectionActionAddShortcut,
      .copyToClipboard => l10n.entryActionCopyToClipboard,
      .delete => l10n.entryActionDelete,
      .restore => l10n.entryActionRestore,
      .convert => l10n.entryActionConvert,
      .print => l10n.entryActionPrint,
      .rename => l10n.entryActionRename,
      .copy => l10n.collectionActionCopy,
      .move => l10n.collectionActionMove,
      .share => l10n.entryActionShare,
      .toggleFavourite =>
        // different data depending on toggle state
        l10n.entryActionAddFavourite,
      // raster
      .rotateCCW => l10n.entryActionRotateCCW,
      .rotateCW => l10n.entryActionRotateCW,
      .flip => l10n.entryActionFlip,
      // vector
      .viewSource => l10n.entryActionViewSource,
      // video
      .lockViewer => l10n.viewerActionLock,
      .videoCaptureFrame => l10n.videoActionCaptureFrame,
      .videoToggleMute =>
        // different data depending on toggle state
        l10n.videoActionMute,
      .videoSelectTracks => l10n.videoActionSelectStreams,
      .videoSetSpeed => l10n.videoActionSetSpeed,
      .videoABRepeat => l10n.videoActionABRepeat,
      .videoSettings => l10n.viewerActionSettings,
      .videoTogglePlay =>
        // different data depending on toggle state
        l10n.videoActionPlay,
      .videoReplay10 => l10n.videoActionReplay10,
      .videoSkip10 => l10n.videoActionSkip10,
      .videoShowPreviousFrame => l10n.videoActionShowPreviousFrame,
      .videoShowNextFrame => l10n.videoActionShowNextFrame,
      // external
      .edit => l10n.entryActionEdit,
      .open => l10n.entryActionOpen,
      .openVideoPlayer => l10n.videoControlsPlayOutside,
      .openMap => l10n.entryActionOpenMap,
      .setAs => l10n.entryActionSetAs,
      .cast => l10n.entryActionCast,
      // platform
      .rotateScreen => l10n.entryActionRotateScreen,
      // metadata
      .editDate => l10n.entryInfoActionEditDate,
      .editLocation => l10n.entryInfoActionEditLocation,
      .editTitleDescription => l10n.entryInfoActionEditTitleDescription,
      .editRating => l10n.entryInfoActionEditRating,
      .editTags => l10n.entryInfoActionEditTags,
      .removeMetadata => l10n.entryInfoActionRemoveMetadata,
      .exportMetadata => l10n.entryInfoActionExportMetadata,
      // metadata / GeoTIFF
      .showGeoTiffOnMap => l10n.entryActionShowGeoTiffOnMap,
      // metadata / motion photo
      .convertMotionPhotoToStillImage => l10n.entryActionConvertMotionPhotoToStillImage,
      .viewMotionPhotoVideo => l10n.entryActionViewMotionPhotoVideo,
      // debug
      .debug => 'Debug',
    };
  }

  Widget getIcon() {
    final child = Icon(getIconData());
    return switch (this) {
      .debug => ShaderMask(
        shaderCallback: AvesColorsData.debugGradient.createShader,
        blendMode: BlendMode.srcIn,
        child: child,
      ),
      _ => child,
    };
  }

  IconData getIconData() {
    return switch (this) {
      .info => AIcons.info,
      .addShortcut => AIcons.addShortcut,
      .copyToClipboard => AIcons.clipboard,
      .delete => AIcons.delete,
      .restore => AIcons.restore,
      .convert => AIcons.convert,
      .print => AIcons.print,
      .rename => AIcons.rename,
      .copy => AIcons.copy,
      .move => AIcons.move,
      .share => AIcons.share,
      .toggleFavourite =>
        // different data depending on toggle state
        AIcons.favourite,
      // raster
      .rotateCCW => AIcons.rotateLeft,
      .rotateCW => AIcons.rotateRight,
      .flip => AIcons.flip,
      // vector
      .viewSource => AIcons.vector,
      // video
      .lockViewer => AIcons.viewerLock,
      .videoCaptureFrame => AIcons.captureFrame,
      .videoToggleMute =>
        // different data depending on toggle state
        AIcons.mute,
      .videoSelectTracks => AIcons.selectTracks,
      .videoSetSpeed => AIcons.setSpeed,
      .videoABRepeat => AIcons.repeat,
      .videoSettings => AIcons.videoSettings,
      .videoTogglePlay =>
        // different data depending on toggle state
        AIcons.play,
      .videoReplay10 => AIcons.replay10,
      .videoSkip10 => AIcons.skip10,
      .videoShowPreviousFrame => AIcons.previousFrame,
      .videoShowNextFrame => AIcons.nextFrame,
      // external
      .edit => AIcons.edit,
      .open => AIcons.openOutside,
      .openVideoPlayer => AIcons.openOutside,
      .openMap => AIcons.map,
      .setAs => AIcons.setAs,
      .cast => AIcons.cast,
      // platform
      .rotateScreen => AIcons.rotateScreen,
      // metadata
      .editDate => AIcons.date,
      .editLocation => AIcons.location,
      .editTitleDescription => AIcons.description,
      .editRating => AIcons.rating,
      .editTags => AIcons.tag,
      .removeMetadata => AIcons.clear,
      .exportMetadata => AIcons.fileExport,
      // metadata / GeoTIFF
      .showGeoTiffOnMap => AIcons.map,
      // metadata / motion photo
      .convertMotionPhotoToStillImage => AIcons.convertToStillImage,
      .viewMotionPhotoVideo => AIcons.openVideoPart,
      // debug
      .debug => AIcons.debug,
    };
  }
}
