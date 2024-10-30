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
  lockViewer,
  videoCaptureFrame,
  videoSelectStreams,
  videoSetSpeed,
  videoABRepeat,
  videoToggleMute,
  videoSettings,
  videoTogglePlay,
  videoReplay10,
  videoSkip10,
  videoShowPreviousFrame,
  videoShowNextFrame,
  // external
  edit,
  open,
  openVideoPlayer,
  openMap,
  setAs,
  cast,
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
    ...exportInternal,
    ...exportExternal,
  ];

  static const exportInternal = [
    EntryAction.convert,
    EntryAction.addShortcut,
    EntryAction.copyToClipboard,
    EntryAction.print,
  ];

  static const exportExternal = [
    EntryAction.open,
    EntryAction.openMap,
    EntryAction.setAs,
    EntryAction.cast,
  ];

  static const pageActions = {
    EntryAction.videoCaptureFrame,
    EntryAction.videoSelectStreams,
    EntryAction.videoSetSpeed,
    EntryAction.videoABRepeat,
    EntryAction.videoToggleMute,
    EntryAction.videoSettings,
    EntryAction.videoTogglePlay,
    EntryAction.videoReplay10,
    EntryAction.videoSkip10,
    EntryAction.videoShowPreviousFrame,
    EntryAction.videoShowNextFrame,
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
    EntryAction.flip,
  };

  static const trashed = [
    EntryAction.delete,
    EntryAction.restore,
    EntryAction.debug,
  ];

  static const video = [
    EntryAction.videoCaptureFrame,
    EntryAction.videoToggleMute,
    EntryAction.videoSetSpeed,
    EntryAction.videoABRepeat,
    EntryAction.videoSelectStreams,
    EntryAction.videoSettings,
    EntryAction.lockViewer,
  ];

  static const videoPlayback = [
    EntryAction.videoReplay10,
    EntryAction.videoShowPreviousFrame,
    EntryAction.videoTogglePlay,
    EntryAction.videoShowNextFrame,
    EntryAction.videoSkip10,
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
