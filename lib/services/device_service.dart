import 'dart:ui';

import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class DeviceService {
  Future<Map<String, dynamic>> getCapabilities();

  Future<String?> getDefaultTimeZone();

  Future<List<Locale>> getLocales();

  Future<int> getPerformanceClass();

  Future<bool> isSystemFilePickerEnabled();
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
  Future<List<Locale>> getLocales() async {
    try {
      final result = await platform.invokeMethod('getLocales');
      if (result != null) {
        return (result as List).cast<Map>().map((tags) {
          final language = tags['language'] as String?;
          final country = tags['country'] as String?;
          return Locale(
            language ?? 'und',
            (country != null && country.isEmpty) ? null : country,
          );
        }).toList();
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<int> getPerformanceClass() async {
    try {
      final result = await platform.invokeMethod('getPerformanceClass');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }

  @override
  Future<bool> isSystemFilePickerEnabled() async {
    try {
      final result = await platform.invokeMethod('isSystemFilePickerEnabled');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }
}
