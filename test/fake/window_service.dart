import 'package:aves/services/window_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWindowService extends Fake implements WindowService {
  @override
  Future<bool> isRotationLocked() => SynchronousFuture(false);
}
