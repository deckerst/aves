enum AppMode { main, pickMediaExternal, pickMediaInternal, pickFilterInternal, view }

extension ExtraAppMode on AppMode {
  bool get canSearch => this == AppMode.main || this == AppMode.pickMediaExternal;

  bool get canSelect => this == AppMode.main;

  bool get hasDrawer => this == AppMode.main || this == AppMode.pickMediaExternal;

  bool get isPickingMedia => this == AppMode.pickMediaExternal || this == AppMode.pickMediaInternal;
}
