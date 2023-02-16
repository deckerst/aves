enum AppMode {
  main,
  pickCollectionFiltersExternal,
  pickSingleMediaExternal,
  pickMultipleMediaExternal,
  pickMediaInternal,
  pickFilterInternal,
  screenSaver,
  setWallpaper,
  slideshow,
  view,
}

extension ExtraAppMode on AppMode {
  bool get canNavigate => {
        AppMode.main,
        AppMode.pickCollectionFiltersExternal,
        AppMode.pickSingleMediaExternal,
        AppMode.pickMultipleMediaExternal,
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
        AppMode.pickMediaInternal,
      }.contains(this);
}
