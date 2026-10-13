import 'dart:ui' as ui;

import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum MemorySizeType { advertised, available, free, max, total, used }

abstract class DeviceService {
  Future<PackageInfo> getPackageInfo();

  Future<AndroidDeviceInfo> getAndroidInfo();

  Future<bool> canAuthenticateUser();

  Future<Map<String, Object?>> getCapabilities();

  Future<List<ui.Locale>> getLocales();

  Future<void> setLocaleConfig(List<ui.Locale> locales);

  // 0 is Sunday
  Future<int?> getFirstDayOfWeekIndex();

  Future<int> getMediaPerformanceClass();

  Future<double?> getWidgetCornerRadiusPx();

  Future<bool> isLocked();

  Future<bool> isSystemFilePickerEnabled();

  Future<bool> isMediaManagementGranted();

  Future<void> requestMediaManagementPermission();

  Future<int?> getAvailableProcessors();

  Future<Map<MemorySizeType, int?>> getHeapSizes(Set<MemorySizeType> types);

  Future<Map<MemorySizeType, int?>> getRamSizes(Set<MemorySizeType> types);

  Future<void> requestGarbageCollection();
}

class PlatformDeviceService extends DeviceService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/device');

  @override
  Future<PackageInfo> getPackageInfo() => PackageInfo.fromPlatform();

  @override
  Future<AndroidDeviceInfo> getAndroidInfo() => DeviceInfoPlugin().androidInfo;

  @override
  Future<bool> canAuthenticateUser() async {
    final auth = LocalAuthentication();
    return await auth.canCheckBiometrics || await auth.isDeviceSupported();
  }

  @override
  Future<Map<String, Object?>> getCapabilities() async {
    try {
      final result = await _platform.invokeMethod('getCapabilities');
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<List<ui.Locale>> getLocales() async {
    try {
      final result = await _platform.invokeMethod('getLocales');
      if (result != null) {
        return (result as List).cast<Map>().map((tags) {
          final language = tags['language'] as String?;
          final country = tags['country'] as String?;
          return ui.Locale(
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
  Future<void> setLocaleConfig(List<ui.Locale> locales) async {
    try {
      await _platform.invokeMethod('setLocaleConfig', <String, Object?>{
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
  Future<int> getMediaPerformanceClass() async {
    try {
      final result = await _platform.invokeMethod('getMediaPerformanceClass');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }

  @override
  Future<double?> getWidgetCornerRadiusPx() async {
    try {
      final result = await _platform.invokeMethod('getWidgetCornerRadiusPx');
      if (result != null) return result as double;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
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
  Future<bool> isMediaManagementGranted() async {
    try {
      final result = await _platform.invokeMethod('isMediaManagementGranted');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<void> requestMediaManagementPermission() async {
    try {
      await _platform.invokeMethod('requestMediaManagementPermission');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<int?> getAvailableProcessors() async {
    try {
      final result = await _platform.invokeMethod('getAvailableProcessors');
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<Map<MemorySizeType, int?>> getHeapSizes(Set<MemorySizeType> types) async {
    try {
      final result = await _platform.invokeMethod('getHeapSizes', <String, Object?>{
        'types': types.map((v) => v.name).toList(),
      });
      if (result is Map) return result.cast<String, int?>().map((k, v) => MapEntry(MemorySizeType.values.safeByName(k)!, v));
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map<MemorySizeType, int?>> getRamSizes(Set<MemorySizeType> types) async {
    try {
      final result = await _platform.invokeMethod('getRamSizes', <String, Object?>{
        'types': types.map((v) => v.name).toList(),
      });
      if (result is Map) return result.cast<String, int?>().map((k, v) => MapEntry(MemorySizeType.values.safeByName(k)!, v));
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
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
