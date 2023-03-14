import 'package:aves/model/settings/enums/enums.dart';
import 'package:flutter/material.dart';

extension ExtraAvesThemeBrightness on AvesThemeBrightness {
  ThemeMode get appThemeMode {
    switch (this) {
      case AvesThemeBrightness.system:
        return ThemeMode.system;
      case AvesThemeBrightness.light:
        return ThemeMode.light;
      case AvesThemeBrightness.dark:
      case AvesThemeBrightness.black:
        return ThemeMode.dark;
    }
  }
}
