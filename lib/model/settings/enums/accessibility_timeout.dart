import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraAccessibilityTimeout on AccessibilityTimeout {
  String getName(BuildContext context) {
    switch (this) {
      case AccessibilityTimeout.system:
        return context.l10n.settingsSystemDefault;
      case AccessibilityTimeout.s1:
        return context.l10n.timeSeconds(1);
      case AccessibilityTimeout.s3:
        return context.l10n.timeSeconds(3);
      case AccessibilityTimeout.s5:
        return context.l10n.timeSeconds(5);
      case AccessibilityTimeout.s10:
        return context.l10n.timeSeconds(10);
      case AccessibilityTimeout.s30:
        return context.l10n.timeSeconds(30);
    }
  }
}
