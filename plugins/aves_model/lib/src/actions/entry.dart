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
  videoSelectTracks,
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
  static const topLevel = <EntryAction>[
    .info,
    .share,
    .edit,
    .rename,
    .delete,
    .copy,
    .move,
    .toggleFavourite,
    .rotateScreen,
    .viewSource,
  ];

  static const export = <EntryAction>[
    ...exportInternal,
    ...exportExternal,
  ];

  static const exportInternal = <EntryAction>[
    .convert,
    .addShortcut,
    .copyToClipboard,
    .print,
  ];

  static const exportExternal = <EntryAction>[
    .open,
    .openMap,
    .setAs,
    .cast,
  ];

  static const pageActions = <EntryAction>{
    .videoCaptureFrame,
    .videoToggleMute,
    .videoSetSpeed,
    .videoABRepeat,
    .videoSelectTracks,
    .videoSettings,
    ...videoPlayback,
    ...orientationActions,
  };

  static const orientationActions = <EntryAction>[
    .rotateCCW,
    .rotateCW,
    .flip,
  ];

  static const trashed = <EntryAction>[
    .delete,
    .restore,
    .debug,
  ];

  static const video = <EntryAction>[
    .videoCaptureFrame,
    .videoToggleMute,
    .videoSetSpeed,
    .videoABRepeat,
    .videoSelectTracks,
    .videoSettings,
    .lockViewer,
  ];

  static const videoPlayback = <EntryAction>[
    .videoReplay10,
    .videoShowPreviousFrame,
    .videoTogglePlay,
    .videoShowNextFrame,
    .videoSkip10,
  ];

  static const commonMetadataActions = <EntryAction>[
    .editDate,
    .editLocation,
    .editTitleDescription,
    .editRating,
    .editTags,
    .removeMetadata,
    .exportMetadata,
  ];

  static const formatSpecificMetadataActions = <EntryAction>[
    .showGeoTiffOnMap,
    .convertMotionPhotoToStillImage,
    .viewMotionPhotoVideo,
  ];
}
