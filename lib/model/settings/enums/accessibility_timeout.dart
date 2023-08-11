import 'package:aves/services/accessibility_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraAccessibilityTimeout on AccessibilityTimeout {
  Future<Duration> getSnackBarDuration(bool hasAction) async {
    switch (this) {
      case AccessibilityTimeout.system:
        if (hasAction) {
          return Duration(milliseconds: await (AccessibilityService.getRecommendedTimeToTakeAction(ADurations.opToastActionDisplay)));
        } else {
          return Duration(milliseconds: await (AccessibilityService.getRecommendedTimeToRead(ADurations.opToastTextDisplay)));
        }
      case AccessibilityTimeout.s1:
        return const Duration(seconds: 1);
      case AccessibilityTimeout.s3:
        return const Duration(seconds: 3);
      case AccessibilityTimeout.s5:
        return const Duration(seconds: 5);
      case AccessibilityTimeout.s10:
        return const Duration(seconds: 10);
      case AccessibilityTimeout.s30:
        return const Duration(seconds: 30);
    }
  }
}
