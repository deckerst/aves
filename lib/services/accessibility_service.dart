import 'package:aves/services/common/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

  static Future<int> getLongPressTimeout() async {
    try {
      final result = await _platform.invokeMethod('getLongPressTimeout');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return kLongPressTimeout.inMilliseconds;
  }

  static bool? _hasRecommendedTimeouts;

  static Future<bool> hasRecommendedTimeouts() async {
    if (_hasRecommendedTimeouts != null) return SynchronousFuture(_hasRecommendedTimeouts!);
    try {
      final result = await _platform.invokeMethod('hasRecommendedTimeouts');
      _hasRecommendedTimeouts = result as bool?;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return _hasRecommendedTimeouts ?? false;
  }

  static Future<int> getRecommendedTimeToRead(Duration originalTimeoutDuration) async {
    final originalTimeoutMillis = originalTimeoutDuration.inMilliseconds;
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

  static Future<int> getRecommendedTimeToTakeAction(Duration originalTimeoutDuration) async {
    final originalTimeoutMillis = originalTimeoutDuration.inMilliseconds;
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

  static Future<bool> shouldUseBoldFont() async {
    try {
      final result = await _platform.invokeMethod('shouldUseBoldFont');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }
}
