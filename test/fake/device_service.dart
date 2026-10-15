import 'package:aves/services/device_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:test/fake.dart';

class FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<PackageInfo> getPackageInfo() => SynchronousFuture(
    PackageInfo(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
    ),
  );

  @override
  Future<AndroidDeviceInfo> getAndroidInfo() => SynchronousFuture(
    AndroidDeviceInfo.fromMap({
      'version': {
        'codename': '',
        'incremental': '',
        'release': '',
        'sdkInt': 0,
      },
      'board': '',
      'bootloader': '',
      'brand': '',
      'device': '',
      'display': '',
      'fingerprint': '',
      'hardware': '',
      'host': '',
      'id': '',
      'manufacturer': '',
      'model': '',
      'product': '',
      'tags': '',
      'time': 0,
      'type': '',
      'isPhysicalDevice': false,
      'freeDiskSize': 0,
      'totalDiskSize': 0,
      'isLowRamDevice': false,
      'physicalRamSize': 0,
      'availableRamSize': 0,
    }),
  );

  @override
  Future<bool> canAuthenticateUser() => SynchronousFuture(true);

  @override
  Future<Map<String, Object?>> getCapabilities() => SynchronousFuture({});

  @override
  Future<int?> getAvailableProcessors() => SynchronousFuture(0);

  @override
  Future<void> requestGarbageCollection() => SynchronousFuture(null);
}
