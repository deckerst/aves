import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class DeviceService {
  Future<Map<String, dynamic>> getCapabilities();

  Future<String?> getDefaultTimeZone();

  Future<int> getPerformanceClass();
}

class PlatformDeviceService implements DeviceService {
  static const platform = MethodChannel('deckers.thibault/aves/device');

  @override
  Future<Map<String, dynamic>> getCapabilities() async {
    try {
      final result = await platform.invokeMethod('getCapabilities');
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<String?> getDefaultTimeZone() async {
    try {
      return await platform.invokeMethod('getDefaultTimeZone');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<int> getPerformanceClass() async {
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
