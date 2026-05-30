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
  static const general = <ChipSetAction>[
    .configureView,
    .select,
    .selectAll,
    .selectNone,
  ];

  // `null` items are converted to dividers
  static const browsing = <ChipSetAction?>[
    .search,
    .toggleTitleSearch,
    null,
    .map,
    .slideshow,
    .stats,
    null,
    .createAlbum,
    .createVault,
  ];

  // `null` items are converted to dividers
  static const selection = <ChipSetAction?>[
    .setCover,
    .pin,
    .unpin,
    .delete,
    .remove,
    .rename,
    .showCountryStates,
    .hide,
    .group,
    null,
    .showCollection,
    .map,
    .slideshow,
    .stats,
    null,
    .configureVault,
    .lockVault,
  ];
}
