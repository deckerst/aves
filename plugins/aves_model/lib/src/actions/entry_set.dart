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
}

class EntrySetActions {
  static const general = [
    EntrySetAction.configureView,
    EntrySetAction.select,
    EntrySetAction.selectAll,
    EntrySetAction.selectNone,
  ];

  // `null` items are converted to dividers
  static const pageBrowsing = [
    EntrySetAction.searchCollection,
    EntrySetAction.toggleTitleSearch,
    EntrySetAction.addDynamicAlbum,
    EntrySetAction.addShortcut,
    EntrySetAction.setHome,
    null,
    EntrySetAction.map,
    EntrySetAction.slideshow,
    EntrySetAction.stats,
    null,
    EntrySetAction.rescan,
    EntrySetAction.emptyBin,
  ];

  // exclude bin related actions
  static const collectionEditorBrowsing = [
    EntrySetAction.searchCollection,
    EntrySetAction.toggleTitleSearch,
    EntrySetAction.map,
    EntrySetAction.slideshow,
    EntrySetAction.stats,
    // only available as a quick action
    EntrySetAction.selectAll,
  ];

  // `null` items are converted to dividers
  static const pageSelection = [
    EntrySetAction.share,
    EntrySetAction.delete,
    EntrySetAction.restore,
    EntrySetAction.copy,
    EntrySetAction.move,
    EntrySetAction.rename,
    EntrySetAction.toggleFavourite,
    null,
    EntrySetAction.map,
    EntrySetAction.slideshow,
    EntrySetAction.stats,
    null,
    EntrySetAction.rescan,
    // export and editing actions are in their subsections
  ];

  // exclude bin related actions
  static const collectionEditorSelectionRegular = [
    EntrySetAction.share,
    EntrySetAction.delete,
    EntrySetAction.copy,
    EntrySetAction.move,
    EntrySetAction.rename,
    EntrySetAction.toggleFavourite,
    EntrySetAction.convert,
    EntrySetAction.exportGpx,
    EntrySetAction.map,
    EntrySetAction.slideshow,
    EntrySetAction.stats,
    EntrySetAction.selectAll,
    // editing actions are in their subsection
  ];

  static const collectionEditorSelectionEdit = [
    EntrySetAction.rotateCCW,
    EntrySetAction.rotateCW,
    EntrySetAction.flip,
    EntrySetAction.editDate,
    EntrySetAction.editLocation,
    EntrySetAction.editTitleDescription,
    EntrySetAction.editRating,
    EntrySetAction.editTags,
    EntrySetAction.removeMetadata,
  ];

  static const edit = [
    EntrySetAction.editDate,
    EntrySetAction.editLocation,
    EntrySetAction.editTitleDescription,
    EntrySetAction.editRating,
    EntrySetAction.editTags,
    EntrySetAction.removeMetadata,
  ];

  static const export = [
    EntrySetAction.convert,
    EntrySetAction.exportGpx,
  ];
}
