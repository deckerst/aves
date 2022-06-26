import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

class AccessibilityService {
  static const _platform = MethodChannel('deckers.thibault/aves/accessibility');

  static Future<bool> areAnimationsRemoved() async {
    try {
      final result = await _platform.invokeMethod('areAnimationsRemoved');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  static Future<bool> hasRecommendedTimeouts() async {
    try {
      final result = await _platform.invokeMethod('hasRecommendedTimeouts');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  static Future<int> getRecommendedTimeToRead(int originalTimeoutMillis) async {
    try {
      final result = await _platform.invokeMethod('getRecommendedTimeoutMillis', <String, dynamic>{
        'originalTimeoutMillis': originalTimeoutMillis,
        'content': ['icons', 'text']
      });
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return originalTimeoutMillis;
  }

  static Future<int> getRecommendedTimeToTakeAction(int originalTimeoutMillis) async {
    try {
      final result = await _platform.invokeMethod('getRecommendedTimeoutMillis', <String, dynamic>{
        'originalTimeoutMillis': originalTimeoutMillis,
        'content': ['controls', 'icons', 'text']
      });
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return originalTimeoutMillis;
  }
}
