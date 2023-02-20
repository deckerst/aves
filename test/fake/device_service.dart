import 'package:aves/services/device_service.dart';
import 'package:flutter/foundation.dart';
import 'package:test/fake.dart';

class FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<int> getDefaultTimeZoneRawOffsetMillis() => SynchronousFuture(3600000);
}
