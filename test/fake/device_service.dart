import 'package:aves/services/device_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<String> getDefaultTimeZone() => SynchronousFuture('');
}
