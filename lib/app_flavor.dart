enum AppFlavor { play, huawei, izzy }

extension ExtraAppFlavor on AppFlavor {
  bool get canEnableErrorReporting {
    switch (this) {
      case AppFlavor.play:
        return true;
      case AppFlavor.huawei:
      case AppFlavor.izzy:
        return false;
    }
  }
}
