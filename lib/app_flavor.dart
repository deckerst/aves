enum AppFlavor { play, izzy, libre }

extension ExtraAppFlavor on AppFlavor {
  bool get canEnableErrorReporting {
    switch (this) {
      case AppFlavor.play:
        return true;
      case AppFlavor.izzy:
      case AppFlavor.libre:
        return false;
    }
  }

  bool get hasMapStyleDefault {
    switch (this) {
      case AppFlavor.play:
        return true;
      case AppFlavor.izzy:
      case AppFlavor.libre:
        return false;
    }
  }
}
