enum AppFlavor { play, izzy }

extension ExtraAppFlavor on AppFlavor {
  bool get canEnableErrorReporting => this == AppFlavor.play;
}
