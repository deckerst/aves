import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/services.dart';

class WallpaperService {
  static const _platform = MethodChannel('deckers.thibault/aves/wallpaper');

  static Future<bool> set(Uint8List bytes, WallpaperTarget target) async {
    try {
      await _platform.invokeMethod('setWallpaper', <String, dynamic>{
        'bytes': bytes,
        'home': {WallpaperTarget.home, WallpaperTarget.homeLock}.contains(target),
        'lock': {WallpaperTarget.lock, WallpaperTarget.homeLock}.contains(target),
      });
      return true;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }
}
