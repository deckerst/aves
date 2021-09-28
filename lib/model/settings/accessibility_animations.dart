import 'dart:ui';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraAccessibilityAnimations on AccessibilityAnimations {
  String getName(BuildContext context) {
    switch (this) {
      case AccessibilityAnimations.system:
        return context.l10n.settingsSystemDefault;
      case AccessibilityAnimations.disabled:
        return context.l10n.accessibilityAnimationsRemove;
      case AccessibilityAnimations.enabled:
        return context.l10n.accessibilityAnimationsKeep;
    }
  }

  bool get animate {
    switch (this) {
      case AccessibilityAnimations.system:
        return !window.accessibilityFeatures.disableAnimations;
      case AccessibilityAnimations.disabled:
        return false;
      case AccessibilityAnimations.enabled:
        return true;
    }
  }
}
