enum AppMode {
  initialization,
  main,
  pickCollectionFiltersExternal,
  pickSingleMediaExternal,
  pickMultipleMediaExternal,
  pickFilteredMediaInternal,
  pickUnfilteredMediaInternal,
  pickFilterInternal,
  previewMap,
  screenSaver,
  setWallpaper,
  slideshow,
  view,
  edit,
}

extension ExtraAppMode on AppMode {
  bool get canNavigate => <AppMode>{
    .main,
    .pickCollectionFiltersExternal,
    .pickSingleMediaExternal,
    .pickMultipleMediaExternal,
  }.contains(this);

  bool get canEditEntry => <AppMode>{
    .main,
    .view,
  }.contains(this);

  bool get canSelectMedia => <AppMode>{
    .main,
    .pickMultipleMediaExternal,
  }.contains(this);

  bool get canSelectFilter => <AppMode>{
    .main,
    .pickCollectionFiltersExternal,
  }.contains(this);

  bool get canCreateFilter => <AppMode>{
    .main,
    .pickFilterInternal,
  }.contains(this);

  bool get isPickingMedia => <AppMode>{
    .pickSingleMediaExternal,
    .pickMultipleMediaExternal,
    .pickFilteredMediaInternal,
    .pickUnfilteredMediaInternal,
  }.contains(this);
}
