import 'package:aves/services/services.dart';
import 'package:flutter/services.dart';

class DeviceService {
  static const platform = MethodChannel('deckers.thibault/aves/device');

  static Future<int> getPerformanceClass() async {
    try {
      await platform.invokeMethod('getPerformanceClass');
      final result = await platform.invokeMethod('getPerformanceClass');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }
}
