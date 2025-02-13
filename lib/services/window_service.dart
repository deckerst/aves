import 'package:aves/services/common/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract class WindowService {
  Future<bool> isActivity();

  Future<void> keepScreenOn(bool on);

  Future<void> secureScreen(bool on);

  Future<bool> isRotationLocked();

  Future<void> requestOrientation([Orientation? orientation]);

  Future<bool> isCutoutAware();

  Future<EdgeInsets> getCutoutInsets();

  Future<bool> supportsWideGamut();

  Future<bool> supportsHdr();

  Future<void> setHdrColorMode(bool on);
}

class PlatformWindowService implements WindowService {
  static const _platform = MethodChannel('deckers.thibault/aves/window');

  bool? _isCutoutAware, _supportsHdr, _supportsWideGamut;

  @override
  Future<bool> isActivity() async {
    try {
      final result = await _platform.invokeMethod('isActivity');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<void> keepScreenOn(bool on) async {
    try {
      await _platform.invokeMethod('keepScreenOn', <String, dynamic>{
        'on': on,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<void> secureScreen(bool on) async {
    try {
      await _platform.invokeMethod('secureScreen', <String, dynamic>{
        'on': on,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<bool> isRotationLocked() async {
    try {
      final result = await _platform.invokeMethod('isRotationLocked');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
      case Orientation.portrait:
        // SCREEN_ORIENTATION_SENSOR_PORTRAIT
        orientationCode = 7;
      default:
        // SCREEN_ORIENTATION_UNSPECIFIED
        orientationCode = -1;
    }
    try {
      await _platform.invokeMethod('requestOrientation', <String, dynamic>{
        'orientation': orientationCode,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<bool> isCutoutAware() async {
    if (_isCutoutAware != null) return SynchronousFuture(_isCutoutAware!);
    try {
      final result = await _platform.invokeMethod('isCutoutAware');
      _isCutoutAware = result as bool?;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return _isCutoutAware ?? false;
  }

  @override
  Future<EdgeInsets> getCutoutInsets() async {
    try {
      final result = await _platform.invokeMethod('getCutoutInsets');
      if (result != null) {
        return EdgeInsets.only(
          left: result['left']?.toDouble() ?? 0,
          top: result['top']?.toDouble() ?? 0,
          right: result['right']?.toDouble() ?? 0,
          bottom: result['bottom']?.toDouble() ?? 0,
        );
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return EdgeInsets.zero;
  }

  @override
  Future<bool> supportsWideGamut() async {
    if (_supportsWideGamut != null) return SynchronousFuture(_supportsWideGamut!);
    try {
      final result = await _platform.invokeMethod('supportsWideGamut');
      _supportsWideGamut = result as bool?;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return _supportsWideGamut ?? false;
  }

  @override
  Future<bool> supportsHdr() async {
    if (_supportsHdr != null) return SynchronousFuture(_supportsHdr!);
    try {
      final result = await _platform.invokeMethod('supportsHdr');
      _supportsHdr = result as bool?;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return _supportsHdr ?? false;
  }

  @override
  Future<void> setHdrColorMode(bool on) async {
    // TODO TLAD [hdr] enable when ready
    // try {
    //   await _platform.invokeMethod('setHdrColorMode', <String, dynamic>{
    //     'on': on,
    //   });
    // } on PlatformException catch (e, stack) {
    //   await reportService.recordError(e, stack);
    // }
  }
}
