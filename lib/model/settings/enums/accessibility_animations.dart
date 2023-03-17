import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';

extension ExtraAccessibilityAnimations on AccessibilityAnimations {
  bool get animate {
    switch (this) {
      case AccessibilityAnimations.system:
        // as of Flutter v2.5.1, the check for `disableAnimations` is unreliable
        // so we cannot use `window.accessibilityFeatures.disableAnimations` nor `MediaQuery.of(context).disableAnimations`
        return !settings.areAnimationsRemoved;
      case AccessibilityAnimations.disabled:
        return false;
      case AccessibilityAnimations.enabled:
        return true;
    }
  }
}
