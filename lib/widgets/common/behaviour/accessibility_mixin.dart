import 'dart:ui';

import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';

mixin AccessibilityMixin {
  bool areAnimationsEnabled() {
    switch (settings.accessibilityAnimations) {
      case AccessibilityAnimations.system:
        return !window.accessibilityFeatures.disableAnimations;
      case AccessibilityAnimations.disabled:
        return false;
      case AccessibilityAnimations.enabled:
        return true;
    }
  }
}
