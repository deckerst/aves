import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class TimeService {
  Future<String?> getDefaultTimeZone();
}

class PlatformTimeService implements TimeService {
  static const platform = MethodChannel('deckers.thibault/aves/time');

  @override
  Future<String?> getDefaultTimeZone() async {
    try {
      return await platform.invokeMethod('getDefaultTimeZone');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}
