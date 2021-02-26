import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TimeService {
  static const platform = MethodChannel('deckers.thibault/aves/time');

  static Future<String> getDefaultTimeZone() async {
    try {
      return await platform.invokeMethod('getDefaultTimeZone');
    } on PlatformException catch (e) {
      debugPrint('getDefaultTimeZone failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }
}
