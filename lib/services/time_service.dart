import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class TimeService {
  Future<String> getDefaultTimeZone();
}

class PlatformTimeService implements TimeService {
  static const platform = MethodChannel('deckers.thibault/aves/time');

  @override
  Future<String> getDefaultTimeZone() async {
    try {
      return await platform.invokeMethod('getDefaultTimeZone');
    } on PlatformException catch (e) {
      debugPrint('getDefaultTimeZone failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }
}
