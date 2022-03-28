import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

extension ExtraAvesThemeBrightness on AvesThemeBrightness {
  String getName(BuildContext context) {
    switch (this) {
      case AvesThemeBrightness.system:
        return context.l10n.settingsSystemDefault;
      case AvesThemeBrightness.light:
        return context.l10n.themeBrightnessLight;
      case AvesThemeBrightness.dark:
        return context.l10n.themeBrightnessDark;
      case AvesThemeBrightness.black:
        return context.l10n.themeBrightnessBlack;
    }
  }

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
