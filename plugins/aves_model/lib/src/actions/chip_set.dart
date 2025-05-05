enum ChipSetAction {
  // general
  configureView,
  select,
  selectAll,
  selectNone,
  // browsing
  search,
  toggleTitleSearch,
  createGroup,
  createAlbum,
  createVault,
  // browsing or selecting
  map,
  slideshow,
  stats,
  // selecting (single/multiple filters)
  delete,
  remove,
  hide,
  pin,
  unpin,
  group,
  lockVault,
  showCountryStates,
  showCollection,
  // selecting (single filter)
  rename,
  setCover,
  configureVault,
}

class ChipSetActions {
  static const general = [
    ChipSetAction.configureView,
    ChipSetAction.select,
    ChipSetAction.selectAll,
    ChipSetAction.selectNone,
  ];

  // `null` items are converted to dividers
  static const browsing = [
    ChipSetAction.search,
    ChipSetAction.toggleTitleSearch,
    null,
    ChipSetAction.map,
    ChipSetAction.slideshow,
    ChipSetAction.stats,
    null,
    ChipSetAction.createAlbum,
    ChipSetAction.createVault,
  ];

  // `null` items are converted to dividers
  static const selection = [
    ChipSetAction.setCover,
    ChipSetAction.pin,
    ChipSetAction.unpin,
    ChipSetAction.delete,
    ChipSetAction.remove,
    ChipSetAction.rename,
    ChipSetAction.showCountryStates,
    ChipSetAction.hide,
    ChipSetAction.group,
    null,
    ChipSetAction.showCollection,
    ChipSetAction.map,
    ChipSetAction.slideshow,
    ChipSetAction.stats,
    null,
    ChipSetAction.configureVault,
    ChipSetAction.lockVault,
  ];
}
