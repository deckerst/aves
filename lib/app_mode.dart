enum AppMode {
  main,
  pickCollectionFiltersExternal,
  pickSingleMediaExternal,
  pickMultipleMediaExternal,
  pickFilteredMediaInternal,
  pickUnfilteredMediaInternal,
  pickFilterInternal,
  screenSaver,
  setWallpaper,
  slideshow,
  view,
  edit,
}

extension ExtraAppMode on AppMode {
  bool get canNavigate => {
        AppMode.main,
        AppMode.pickCollectionFiltersExternal,
        AppMode.pickSingleMediaExternal,
        AppMode.pickMultipleMediaExternal,
      }.contains(this);

  bool get canEditEntry => {
        AppMode.main,
        AppMode.view,
      }.contains(this);

  bool get canSelectMedia => {
        AppMode.main,
        AppMode.pickMultipleMediaExternal,
      }.contains(this);

  bool get canSelectFilter => this == AppMode.main;

  bool get canCreateFilter => {
        AppMode.main,
        AppMode.pickFilterInternal,
      }.contains(this);

  bool get isPickingMedia => {
        AppMode.pickSingleMediaExternal,
        AppMode.pickMultipleMediaExternal,
        AppMode.pickFilteredMediaInternal,
        AppMode.pickUnfilteredMediaInternal,
      }.contains(this);
}
