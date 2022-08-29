import 'package:aves/services/device_service.dart';
import 'package:flutter/foundation.dart';
import 'package:test/fake.dart';

class FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<String> getDefaultTimeZone() => SynchronousFuture('');
}
