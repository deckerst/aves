import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract class WindowService {
  Future<void> keepScreenOn(bool on);

  Future<bool> isRotationLocked();

  Future<void> requestOrientation([Orientation? orientation]);

  Future<bool> canSetCutoutMode();

  Future<void> setCutoutMode(bool use);
}

class PlatformWindowService implements WindowService {
  static const platform = MethodChannel('deckers.thibault/aves/window');

  @override
  Future<void> keepScreenOn(bool on) async {
    try {
      await platform.invokeMethod('keepScreenOn', <String, dynamic>{
        'on': on,
      });
    } on PlatformException catch (e) {
      debugPrint('keepScreenOn failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  @override
  Future<bool> isRotationLocked() async {
    try {
      final result = await platform.invokeMethod('isRotationLocked');
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('isRotationLocked failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  @override
  Future<void> requestOrientation([Orientation? orientation]) async {
    // cf Android `ActivityInfo.ScreenOrientation`
    late final int orientationCode;
    switch (orientation) {
      case Orientation.landscape:
        // SCREEN_ORIENTATION_SENSOR_LANDSCAPE
        orientationCode = 6;
        break;
      case Orientation.portrait:
        // SCREEN_ORIENTATION_SENSOR_PORTRAIT
        orientationCode = 7;
        break;
      default:
        // SCREEN_ORIENTATION_UNSPECIFIED
        orientationCode = -1;
        break;
    }
    try {
      await platform.invokeMethod('requestOrientation', <String, dynamic>{
        'orientation': orientationCode,
      });
    } on PlatformException catch (e) {
      debugPrint('requestOrientation failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  @override
  Future<bool> canSetCutoutMode() async {
    try {
      final result = await platform.invokeMethod('canSetCutoutMode');
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('canSetCutoutMode failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  @override
  Future<void> setCutoutMode(bool use) async {
    try {
      await platform.invokeMethod('setCutoutMode', <String, dynamic>{
        'use': use,
      });
    } on PlatformException catch (e) {
      debugPrint('setCutoutMode failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}
