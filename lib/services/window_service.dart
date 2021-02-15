import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WindowService {
  static const platform = MethodChannel('deckers.thibault/aves/window');

  static Future<void> keepScreenOn(bool on) async {
    try {
      await platform.invokeMethod('keepScreenOn', <String, dynamic>{
        'on': on,
      });
    } on PlatformException catch (e) {
      debugPrint('keepScreenOn failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}
