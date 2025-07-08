import 'dart:ui';

import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

abstract class DeviceService {
  Future<bool> canManageMedia();

  Future<Map<String, dynamic>> getCapabilities();

  Future<List<Locale>> getLocales();

  Future<void> setLocaleConfig(List<Locale> locales);

  Future<int?> getFirstDayOfWeekIndex();

  Future<int> getPerformanceClass();

  Future<bool> isLocked();

  Future<bool> isSystemFilePickerEnabled();

  Future<void> requestMediaManagePermission();

  Future<int> getAvailableHeapSize();

  Future<void> requestGarbageCollection();
}

class PlatformDeviceService implements DeviceService {
  static const _platform = MethodChannel('deckers.thibault/aves/device');

  @override
  Future<bool> canManageMedia() async {
    try {
      final result = await _platform.invokeMethod('canManageMedia');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>> getCapabilities() async {
    try {
      final result = await _platform.invokeMethod('getCapabilities');
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<List<Locale>> getLocales() async {
    try {
      final result = await _platform.invokeMethod('getLocales');
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
  Future<void> setLocaleConfig(List<Locale> locales) async {
    try {
      await _platform.invokeMethod('setLocaleConfig', <String, dynamic>{
        'locales': locales.map((v) => v.toLanguageTag()).toList(),
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<int?> getFirstDayOfWeekIndex() async {
    try {
      final result = await _platform.invokeMethod('getFirstDayOfWeek');
      if (result != null) {
        final day = result as String;
        final index = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].indexOf(day);
        if (index >= 0) {
          return index;
        }
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<int> getPerformanceClass() async {
    try {
      final result = await _platform.invokeMethod('getPerformanceClass');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }

  @override
  Future<bool> isLocked() async {
    try {
      final result = await _platform.invokeMethod('isLocked');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool> isSystemFilePickerEnabled() async {
    try {
      final result = await _platform.invokeMethod('isSystemFilePickerEnabled');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<void> requestMediaManagePermission() async {
    try {
      await _platform.invokeMethod('requestMediaManagePermission');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<int> getAvailableHeapSize() async {
    try {
      final result = await _platform.invokeMethod('getAvailableHeapSize');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }

  @override
  Future<void> requestGarbageCollection() async {
    try {
      await _platform.invokeMethod('requestGarbageCollection');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}
