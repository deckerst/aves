enum AppMode {
  main,
  pickSingleMediaExternal,
  pickMultipleMediaExternal,
  pickMediaInternal,
  pickFilterInternal,
  setWallpaper,
  slideshow,
  view,
}

extension ExtraAppMode on AppMode {
  bool get canSearch => this == AppMode.main || this == AppMode.pickSingleMediaExternal || this == AppMode.pickMultipleMediaExternal;

  bool get canSelectMedia => this == AppMode.main || this == AppMode.pickMultipleMediaExternal;

  bool get canSelectFilter => this == AppMode.main;

  bool get hasDrawer => this == AppMode.main || this == AppMode.pickSingleMediaExternal || this == AppMode.pickMultipleMediaExternal;

  bool get isPickingMedia => this == AppMode.pickSingleMediaExternal || this == AppMode.pickMultipleMediaExternal || this == AppMode.pickMediaInternal;
}
