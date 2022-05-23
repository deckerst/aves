import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraAccessibilityTimeout on AccessibilityTimeout {
  String getName(BuildContext context) {
    switch (this) {
      case AccessibilityTimeout.system:
        return context.l10n.settingsSystemDefault;
      case AccessibilityTimeout.appDefault:
        return context.l10n.settingsDefault;
      case AccessibilityTimeout.s3:
        return context.l10n.timeSeconds(3);
      case AccessibilityTimeout.s10:
        return context.l10n.timeSeconds(10);
      case AccessibilityTimeout.s30:
        return context.l10n.timeSeconds(30);
      case AccessibilityTimeout.s60:
        return context.l10n.timeMinutes(1);
      case AccessibilityTimeout.s120:
        return context.l10n.timeMinutes(2);
    }
  }
}
