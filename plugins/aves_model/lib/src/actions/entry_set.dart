enum EntrySetAction {
  // general
  configureView,
  select,
  selectAll,
  selectNone,
  // browsing
  searchCollection,
  toggleTitleSearch,
  addDynamicAlbum,
  addShortcut,
  setHome,
  emptyBin,
  // browsing or selecting
  map,
  slideshow,
  stats,
  rescan,
  // selecting
  share,
  delete,
  restore,
  copy,
  move,
  rename,
  convert,
  exportGpx,
  toggleFavourite,
  rotateCCW,
  rotateCW,
  flip,
  editDate,
  editLocation,
  editTitleDescription,
  editRating,
  editTags,
  removeMetadata,
  // fab
  pickCollectionFilters,
  pickMultipleMedia,
}

class EntrySetActions {
  static const general = <EntrySetAction>[
    .configureView,
    .select,
    .selectAll,
    .selectNone,
  ];

  // `null` items are converted to dividers
  static const pageBrowsing = <EntrySetAction?>[
    .searchCollection,
    .toggleTitleSearch,
    .addDynamicAlbum,
    .addShortcut,
    .setHome,
    null,
    .map,
    .slideshow,
    .stats,
    null,
    .rescan,
    .emptyBin,
  ];

  // exclude bin related actions
  static const collectionEditorBrowsing = <EntrySetAction>[
    .searchCollection,
    .toggleTitleSearch,
    .map,
    .slideshow,
    .stats,
    // only available as a quick action
    .selectAll,
  ];

  // `null` items are converted to dividers
  static const pageSelection = <EntrySetAction?>[
    .share,
    .delete,
    .restore,
    .copy,
    .move,
    .rename,
    .toggleFavourite,
    null,
    .map,
    .slideshow,
    .stats,
    null,
    .rescan,
    // export and editing actions are in their subsections
  ];

  // exclude bin related actions
  static const collectionEditorSelectionRegular = <EntrySetAction>[
    .share,
    .delete,
    .copy,
    .move,
    .rename,
    .toggleFavourite,
    .convert,
    .exportGpx,
    .map,
    .slideshow,
    .stats,
    .selectAll,
    // editing actions are in their subsection
  ];

  static const collectionEditorSelectionEdit = <EntrySetAction>[
    .rotateCCW,
    .rotateCW,
    .flip,
    .editDate,
    .editLocation,
    .editTitleDescription,
    .editRating,
    .editTags,
    .removeMetadata,
  ];

  static const edit = <EntrySetAction>[
    .editDate,
    .editLocation,
    .editTitleDescription,
    .editRating,
    .editTags,
    .removeMetadata,
  ];

  static const export = <EntrySetAction>[
    .convert,
    .exportGpx,
  ];

  static const fab = <EntrySetAction>[
    .pickCollectionFilters,
    .pickMultipleMedia,
  ];
}
