import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class SecurityService {
  Future<bool> writeValue<T>(String key, T? value);

  Future<T?> readValue<T>(String key);
}

class PlatformSecurityService implements SecurityService {
  static const _platform = MethodChannel('deckers.thibault/aves/security');

  @override
  Future<bool> writeValue<T>(String key, T? value) async {
    try {
      await _platform.invokeMethod('writeValue', <String, dynamic>{
        'key': key,
        'value': value,
      });
      return true;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<T?> readValue<T>(String key) async {
    try {
      final result = await _platform.invokeMethod('readValue', <String, dynamic>{
        'key': key,
      });
      if (result != null) return result as T;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}
