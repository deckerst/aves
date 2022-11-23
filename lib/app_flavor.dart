enum AppFlavor { play, huawei, izzy, libre }

extension ExtraAppFlavor on AppFlavor {
  bool get canEnableErrorReporting {
    switch (this) {
      case AppFlavor.play:
        return true;
      case AppFlavor.huawei:
      case AppFlavor.izzy:
      case AppFlavor.libre:
        return false;
    }
  }

  bool get hasMapStyleDefault {
    switch (this) {
      case AppFlavor.play:
      case AppFlavor.huawei:
        return true;
      case AppFlavor.izzy:
      case AppFlavor.libre:
        return false;
    }
  }
}
