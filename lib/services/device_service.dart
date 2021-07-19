import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DeviceService {
  static const platform = MethodChannel('deckers.thibault/aves/device');

  static Future<int> getPerformanceClass() async {
    try {
      await platform.invokeMethod('getPerformanceClass');
      final result = await platform.invokeMethod('getPerformanceClass');
      if (result != null) return result as int;
    } on PlatformException catch (e) {
      debugPrint('getPerformanceClass failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return 0;
  }
}
