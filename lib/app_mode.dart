enum AppMode { main, pickExternal, pickInternal, view }

extension ExtraAppMode on AppMode {
  bool get canSearch => this == AppMode.main || this == AppMode.pickExternal;

  bool get hasDrawer => this == AppMode.main || this == AppMode.pickExternal;

  bool get isPicking => this == AppMode.pickExternal || this == AppMode.pickInternal;
}
