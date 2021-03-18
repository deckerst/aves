import 'package:aves/services/time_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTimeService extends Fake implements TimeService {
  @override
  Future<String> getDefaultTimeZone() => SynchronousFuture('');
}
